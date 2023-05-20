# Code was co-generated with ChatGPT

import requests
from pymongo import MongoClient
import logging
import azure.functions as func
import os


def main(mytimer: func.TimerRequest, outputDocument: func.Out[func.Document]) -> None:
    # URL to poll game data from
    url = "https://pa200527396aa4a.blob.core.windows.net/import/import.json"

    # Make a request to the website to retrieve game data
    response = requests.get(url)
    games = response.json()

    # try:
    conn_string = os.environ["CONN_STRING"]
    client = MongoClient(conn_string)
    db = client.admin
    collection = db.games

    # Process the games
    for game in games:
        # Check if a game with the same name already exists in the collection
        existing_game = collection.find_one({"name": game["name"]})
        if existing_game:
            logging.info(f"Game '{game['name']}' already exists. Skipping insertion.")
            continue

        # Insert the game into the collection
        collection.insert_one(game)
        logging.info(f"Inserted game '{game['name']}' into MongoDB.")

    # Log a message indicating the successful import
    logging.info("Games imported successfully")

    # except Exception as e:
    #    pass
    #    logging.error(f"Error occurred during game import: {str(e)}")
