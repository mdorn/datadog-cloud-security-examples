"""Tiny Flask to-do app for the Datadog attack path lab.

The app is the *carrier* for vulnerable packages. It must stay boring:
no debug mode, no shell-outs, no yaml.load on user input, no S3 access.
"""
import os
import sqlite3

from flask import Flask, g, redirect, render_template, request, url_for

DB_PATH = os.environ.get("TODO_DB", "/tmp/todos.db")

app = Flask(__name__)


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB_PATH)
        g.db.row_factory = sqlite3.Row
        g.db.execute(
            "CREATE TABLE IF NOT EXISTS todos ("
            " id INTEGER PRIMARY KEY AUTOINCREMENT,"
            " title TEXT NOT NULL,"
            " done INTEGER NOT NULL DEFAULT 0)"
        )
    return g.db


@app.teardown_appcontext
def close_db(_exc):
    db = g.pop("db", None)
    if db is not None:
        db.close()


@app.route("/")
def index():
    todos = get_db().execute("SELECT id, title, done FROM todos ORDER BY id DESC").fetchall()
    return render_template("index.html", todos=todos)


@app.route("/add", methods=["POST"])
def add():
    title = (request.form.get("title") or "").strip()[:200]
    if title:
        db = get_db()
        db.execute("INSERT INTO todos (title) VALUES (?)", (title,))
        db.commit()
    return redirect(url_for("index"))


@app.route("/toggle/<int:todo_id>", methods=["POST"])
def toggle(todo_id):
    db = get_db()
    db.execute("UPDATE todos SET done = 1 - done WHERE id = ?", (todo_id,))
    db.commit()
    return redirect(url_for("index"))


@app.route("/delete/<int:todo_id>", methods=["POST"])
def delete(todo_id):
    db = get_db()
    db.execute("DELETE FROM todos WHERE id = ?", (todo_id,))
    db.commit()
    return redirect(url_for("index"))


@app.route("/healthz")
def healthz():
    return "ok", 200


if __name__ == "__main__":
    # Local runs only. debug stays False: the Werkzeug debugger is remote code execution.
    app.run(host="127.0.0.1", port=5000, debug=False)
