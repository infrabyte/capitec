import os

from flask import Flask, jsonify, request
import psycopg2

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=os.environ.get("DB_PORT", "5432"),
        dbname=os.environ.get("DB_NAME", "devops-cyber-assessment"),
        user=os.environ.get("DB_USER", "postgres"),
        password=os.environ.get("DB_PASSWORD", "oh-no!"),
    )


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/expenses", methods=["GET"])
def list_expenses():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, description, amount FROM expenses ORDER BY id;")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(
        [{"id": r[0], "description": r[1], "amount": float(r[2])} for r in rows]
    )


@app.route("/expenses", methods=["POST"])
def add_expense():
    data = request.get_json(force=True)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO expenses (description, amount) VALUES (%s, %s) RETURNING id;",
        (data["description"], data["amount"]),
    )
    new_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(id=new_id), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
