CREATE TABLE IF NOT EXISTS expenses (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO expenses (description, amount) VALUES
  ('Office supplies', 42.50),
  ('Team lunch', 128.75);
