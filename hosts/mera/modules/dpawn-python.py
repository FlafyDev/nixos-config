from flask import Flask, redirect, request
import requests
import json
import os
import time
import jwt
import threading
import datetime
import queue
from collections import defaultdict, deque
from flask_cors import CORS, cross_origin

app = Flask(__name__)
app.secret_key = os.urandom(24)
app.config["SESSION_TYPE"] = "filesystem"
cors = CORS(app) # allow CORS for all domains on all routes.
app.config['CORS_HEADERS'] = 'Content-Type'

# Discord OAuth2
DISCORD_CLIENT_ID = "1368253067094524067"
DISCORD_CLIENT_SECRET = os.environ.get("DISCORD_CLIENT_SECRET")
DISCORD_REDIRECT_URI = "https://dpawn-auth.flafy.dev/callback"
DISCORD_OAUTH2_URL = "https://discord.com/api/oauth2/authorize"
DISCORD_TOKEN_URL = "https://discord.com/api/oauth2/token"
DISCORD_API_URL = "https://discord.com/api/users/@me"
SCOPE = "identify"

MISTRAL_API_KEY = os.environ.get("MISTRAL_API_KEY")

# JWT secret (must be consistent across restarts in production)
JWT_SECRET = os.environ.get("JWT_SECRET")
JWT_ALGORITHM = "HS256"

def create_jwt(user_id):
    payload = {
        "user_id": user_id,
        "exp": datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=1)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

@app.route("/login")
def login():
    return redirect(
        f"{DISCORD_OAUTH2_URL}?client_id={DISCORD_CLIENT_ID}&redirect_uri={DISCORD_REDIRECT_URI}&response_type=code&scope={SCOPE}"
    )

@app.route("/callback")
def callback():
    code = request.args.get("code")
    data = {
        "client_id": DISCORD_CLIENT_ID,
        "client_secret": DISCORD_CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": DISCORD_REDIRECT_URI,
        "scope": SCOPE,
    }

    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    response = requests.post(DISCORD_TOKEN_URL, data=data, headers=headers)
    response.raise_for_status()
    access_token = response.json()["access_token"]

    user_response = requests.get(
        DISCORD_API_URL,
        headers={"Authorization": f"Bearer {access_token}"}
    )
    user = user_response.json()

    jwt_token = create_jwt(user["id"])  # Create token based on Discord user ID

    return f"""
    <html>
    <script>
      window.opener.postMessage({{
        type: 'discord-auth',
        token: '{jwt_token}'
      }}, '*');
      window.close();
    </script>
    <body>Login successful. You can close this window.</body>
    </html>
    """

task_queue = queue.Queue()
lock = threading.Lock()

# Rate limiting: track recent timestamps for each user
past_user_requests = {}

user_tasks = {}  # user_id -> threading.Event, to track pending tasks
user_results = {}  # user_id -> result

RATE_LIMIT = 60
TIME_WINDOW = datetime.timedelta(hours=4)

def worker():
    while True:
        task = task_queue.get()
        task_user_id, task_user_input = task

        res = do_very_expensive_operation(task_user_input)
        
        # Expensive operation needs cooldown of 1 second!
        time.sleep(1)

        # Save the result
        with lock:
            user_results[task_user_id] = res
            if task_user_id in user_tasks:
                user_tasks[task_user_id].set()  # Notify waiting thread

            past_user_requests[task_user_id].append(datetime.datetime.now(datetime.timezone.utc))
            if task_user_id in user_tasks:
                del user_tasks[task_user_id]

        task_queue.task_done()

def start_worker():
    t = threading.Thread(target=worker, name=f"Worker-1")
    t.start()

def send_work(user_id: str, user_input: tuple[int, str]):
    with lock:
        now = datetime.datetime.now(datetime.timezone.utc)

        if user_id not in past_user_requests:
            past_user_requests[user_id] = []

        # Clean up old requests
        for timestamp in past_user_requests[user_id]:
            if timestamp < now - TIME_WINDOW:
                past_user_requests[user_id].remove(timestamp)

        if len(past_user_requests[user_id]) >= RATE_LIMIT:
            raise Exception(f"Rate limit exceeded for user {user_id}")

        if user_id in user_tasks:
            raise Exception(f"Task for user {user_id} is already in progress")

        # Mark user task
        task_event = threading.Event()
        user_tasks[user_id] = task_event
        user_results[user_id] = None

        # Enqueue the task
        task_queue.put((user_id, user_input))

    task_event.wait()
    with lock:
        return user_results.pop(user_id)

@app.route("/api/protected-data", methods=["POST"])
@cross_origin()
def protected_data():
    if not request.is_json or request.json is None:
        return {"error": "Invalid input"}, 400

    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return {"error": "Unauthorized"}, 401

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        user_id = payload["user_id"]

        player_answer = request.json.get("player_answer")
        mystery_id = request.json.get("mystery_id")
        correct = send_work(user_id, (mystery_id, player_answer))

        return {"correct": correct}
    except jwt.ExpiredSignatureError:
        return {"error": "Token expired"}, 401
    except jwt.InvalidTokenError:
        return {"error": "Invalid token"}, 401

# Can only be called once a second (count 1 second from after the function is finished)
def do_very_expensive_operation(user_input: tuple[int, str]) -> bool:
    if user_input[0] not in mysteries:
        print(f"Invalid mystery ID: {user_input[0]}")
        return False
    if len(user_input[1]) > 200:
        print(f"Invalid player answer: {user_input[1]}")
        return False
    
    return check_correct_indexed(user_input[0], user_input[1])

def check_correct_indexed(mystery_id: int, player_answer: str) -> bool:
    return check_correct(mysteries[mystery_id]["ai_question"], mysteries[mystery_id]["ai_correct_answer"], player_answer)

def check_correct(ai_question, ai_correct_answer, player_answer) -> bool:
    url = "https://api.mistral.ai/v1/agents/completions"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
    }

    prompt = json.dumps({
        "question": ai_question,
        "correct_answer": ai_correct_answer,
        "player_answer": player_answer,
    })
    print(prompt)

    # Construct the request payload
    data_obj = {
        "max_tokens": 20,
        "stream": False,
        "stop": "}",
        "messages": [
            {
                "role": "user",
                "content": prompt,
            }
        ],
        "response_format": {
            "type": "json_object",
        },
        "agent_id": "ag:79b4a7bc:20250414:untitled-agent:df400a7a"
    }

    # Send POST request
    response = requests.post(url, headers=headers, json=data_obj)

    # Read and decode the response
    response_text = response.text
    print(response_text)

    try:
        json_response = json.loads(response_text)
        agent_response_text = json_response["choices"][0]["message"]["content"] + "}"
        agent_response_json = json.loads(agent_response_text)
        correct = agent_response_json["correct"]
        return correct > 0.7
    except (KeyError, json.JSONDecodeError) as e:
        print(f"Error parsing response: {e}")
        return False

mysteries = {
    0: {
        "ai_correct_answer": "The girls(students) were [sending] [scary] videos to each other",
        "ai_question": "What were the girls(students) doing in the classroom",
    },
    1: {
        "ai_correct_answer": "[Misbehaving] students are given the altruism internship as [punishment] because of the [lack of members] in the internship.",
        "ai_question": "Why many misbehaving students end up in the altruism internship? And why the altruism internship specifically?"
    },
}

if __name__ == "__main__":
    from waitress import serve

    start_worker()

    # app.run(debug=False, port=6001)
    serve(app, host="127.0.0.1", port=6001)

