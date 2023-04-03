import json


def load_file_to_json(filepath):
    with open(filepath, 'r') as f:
        raw = f.read()
    loaded = json.loads(raw)
    return loaded
