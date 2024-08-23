from src import helpers
from urllib.parse import unquote, quote, urlparse
from _config import *
from flask import request, render_template, jsonify, Response, redirect
import time
import json
import requests
import httpx
import trio
import random

# Debug code uncomment when needed
#import logging, timeit
#logging.basicConfig(level=logging.DEBUG, format="%(message)s")

def imageResults(query) -> Response:
    # get user language settings
    settings = helpers.Settings()

    if request.method == "GET":
        args = request.args
    else:
        args = request.form

    json_path = f'static/lang/{settings.ux_lang}.json'
    with open(json_path, 'r') as file:
        lang_data = helpers.format_araa_name(json.load(file))

    # remember time we started
    start_time = time.time()

    api = args.get("api", "false")

    p = args.get('p', '1')
    if not p.isdigit():
        return redirect('/search')

    # returns 1 if active, else 0
    safe_search = int(settings.safe == "active")

    # grab & format webpage
    json_data, _ = helpers.makeJSONRequest(f"https://api.qwant.com/v3/search/images?t=images&q={quote(query)}&count=50&locale=en_CA&offset={p}&device=desktop&tgp=2&safesearch={safe_search}", http_session="qwant")

    # Get all the images from the response, while avoiding any errors.
    images = json_data.get("data", {}).get("result", {}).get("items", None)
    if images is None:
        return redirect('/search')

    results = []
    for image in images:
        # Get original bing image URL
        bing_url = unquote(urlparse(image['thumbnail']).query).split("u=")[1].split("&")[0]

        image['thumb_proxy'] = f"/img_proxy?url={quote(bing_url)}"

        # Get domain name
        image['source'] = urlparse(image['url']).netloc

        results.append(image)

    # calc. time spent
    end_time = time.time()
    elapsed_time = end_time - start_time

    # render
    if api == "true" and API_ENABLED:
        # return the results list as a JSON response
        return jsonify(results)
    else:
        return render_template("images.html", results=results, title=f"{query} - {ARAA_NAME}",
            q=f"{query}", fetched=f"{elapsed_time:.2f}",
            type="image",
            repo_url=REPO, donate_url=DONATE, API_ENABLED=API_ENABLED,
            TORRENTSEARCH_ENABLED=TORRENTSEARCH_ENABLED, lang_data=lang_data,
            commit=helpers.latest_commit(), settings=settings, araa_name=ARAA_NAME)
