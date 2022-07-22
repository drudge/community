"""
Applet: Twitch
Summary: Display stats for Twitch
Description: Display stats for a Twitch username.
Author: Nicholas Penree
"""

load("encoding/base64.star", "base64")
load("cache.star", "cache")
load("humanize.star", "humanize")
load("http.star", "http")
load("encoding/json.star", "json")
load("render.star", "render")
load("schema.star", "schema")

TWITCH_CLIENT_ID = "h25bh1ddh0f5xcddgxgxhna399677y"

TWITCH_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABQAAAAXCAYAAAALHW+jAAAAAXNSR0IArs4c6QAAAIRlWElmTU0AKgAA
AAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAAB
AAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAABSgAwAEAAAAAQAA
ABcAAAAABkfnLgAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAA
ADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDYuMC4w
Ij4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1z
eW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAg
eG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpP
cmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg
PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KGV7hBwAAA1lJREFUOBGNVUloFEEUfdXdMz0J0bgrgyh6UQ8K
IgrJIVHUJBc9KAY8iJCDQRFFEA+exouCipi4QERBPOpB8OASIiYm4MkcFANGIYkR1IhrMpmtu8v3p6Zn
shjjh+r6Vf//97eqagVS2yYdaX6pci31+gB83En2QCMNfqBEPhtRD2VVQKSSBkWwBn0wGuC2rgDW7YV2
IlBaNGch0bEjwMALYKQHcCSy1jrd5EZwK/kDmLsCQe1+WOq/Yit5Czzgw0XAaqnTh1wHtzKeZIhAB7Cy
TFcoCMwwK/OVPeoUyfcN6+eYLiO1bIU2ggkJoCWMyn85M0qL/I8RoLcDGB81a5G/6zXDtsWCRF1NHMvX
kDIUwYzUfMNIRoaAmzuBMZYkpO4bQA/HVHK4MXO1ChIp+hIqWmE05CuW/t2ykByFs9DMXicbSoQzkxSC
JAX/wjkoNED2krIx0Qt1pbb/BAybs2wVcLgLmLNAoAzVHjGzNCDfPJZD+wj+DSg2NKhcBKyvMQD59jGy
1RvMWo6RAKbH4EXicP4OWEhVJlHOH4NCJHkY8uEJkEa97kb27TVEYxsxOK0pYfhiKHw4Cz9xCJCMV13I
Pq5BFMsw7LuoLkWYD8cUPjUGuGWGt6nhREuRpsfJ04vsvWFk7dsRLd+FofIYNjfdU18Vr55AlYgxu/Pp
nQbjH4G1jUD9IcDLQT9sBYafQ0XnMWUP2UwfI4tjwHKx+eh99U0emmkpg0VOfeL4DIw+Laat759lrU5C
+bznY4PIBl8QVcvx3lHYFILJQyMpT7jqXDEfK8YrTIm7nsA/oR9cQtCfgJq/h4ElkauYCzftod9NY0tz
h/oVPoGSprreMDllyd8ruOA51N4oAisLOxYHcik+pLyGSQ99lFUde6R+P9uqnW2dyjwvtHVo/F6QheQ0
cGLvsFJmHg1dNg82L8pgJoUMuxxL5jAUC7C7+Yn6nZgCRhs436uxRhh0wkrQ09XteqFvo587C8ojsFI5
XDjWrk6JsaiJjsx392m78V4pMtkTKpw0s5Bv2w5dmbbwbo6LxaMZnDverk6XpJKCVmdox5JOrn1BiV3W
BNUqkdD5jo97PL+KYFmcFzDZT0BkRk/xVzMT2ETHec+ycWWnjl+u0yeELwHJ6v/oD9xZSVC/x8FQAAAA
AElFTkSuQmCC
""")

def get_from_twitch_api(path, params, access_token):
    res = http.get(
        url = "https://api.twitch.tv/helix%s" % path,
        params = params,
        headers = {
            "Authorization": "Bearer %s" % access_token,
            "Client-Id": TWITCH_CLIENT_ID,
        },
    )
    return res.json() if res.status_code == 200 else None

def get_twitch_followers(user_id, access_token):
    res = get_from_twitch_api(
        path = "/users/follows",
        params = {
            "to_id": user_id,
        },
        access_token = access_token,
    )
    return res["total"] if res and res["total"] != None else 0

def get_twitch_subscribers(user_id, access_token):
    res = get_from_twitch_api(
        path = "/subscriptions",
        params = {
            "broadcaster_id": user_id,
            "first": "1",
        },
        access_token = access_token,
    )
    return res["total"] if res else None

def get_twitch_user(username, access_token):
    res = get_from_twitch_api(
        path = "/users",
        params = {
            "login": username,
        },
        access_token = access_token,
    )
    if res and res["data"] and len(res["data"]) > 0:
        return res["data"][0]
    return None

def main(config):
    refresh_token = config.get("auth")
    username = config.get("username", "ninja")
    display_mode = config.get("display_mode", "subscribers")
    show_username = config.bool("show_username", "True")
    image_size = 16

    if refresh_token:
        access_token = get_token(refresh_token = refresh_token)
        user = get_twitch_user(
            username = username,
            access_token = access_token,
        )

        # print(user)
        if user == None:
            return []

        display_name = user["display_name"] if user["display_name"] else username

        if display_mode == "followers":
            followers = get_twitch_followers(
                access_token = access_token,
                user_id = user["id"],
            )
            if followers != None:
                msg = "%s %s" % (humanize.comma(followers), display_mode)
                if not show_username:
                    msg = humanize.comma(followers)
                    display_name = display_mode
            else:
                msg = "Check username"
        elif display_mode == "subscribers":
            subscribers = get_twitch_subscribers(
                access_token = access_token,
                user_id = user["id"],
            )

            if subscribers != None:
                msg = "%s subs" % humanize.comma(subscribers)
                if not show_username:
                    msg = humanize.comma(subscribers)
                    display_name = display_mode
            else:
                msg = "Check username"
                display_name = "Are you %s? You can only view your own subscriber count." % display_name
                show_username = True
        else:
            return []

        # print(msg)
    else:
        msg = "Launch Tidbyt app"
        display_name = "Login to Twitch using the Tidbyt app on your phone"
        show_username = True

    username_child = render.Text(
        color = "#3c3c3c" if show_username else "#ffffff",
        content = display_name,
    )

    if len(display_name) > 12:
        username_child = render.Marquee(
            width = 64,
            child = username_child,
        )


    return render.Root(
        child = render.Box(
            render.Column(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly" if len(msg) > 5 else "center",
                        cross_align = "center",
                        children = [
                            render.Padding(
                                pad = (1, 1, 1, 1),
                                child = render.Image(TWITCH_ICON, height = image_size, width = image_size),
                            ),
                            render.WrappedText(msg, font = "tb-8" if show_username or len(msg) > 7 else "6x13"),
                        ],
                    ),
                    username_child,
                ],
            ),
        ),
    )

def get_token(params = None, refresh_token = None):
    has_refresh_token = (refresh_token != None)

    # if we have a refresh token try to get a cached access token and return quickly
    if has_refresh_token:
        access_token = cache.get(refresh_token)
        if access_token != None:
            return access_token

    # if params is a string, assume it is json and decode it
    if type(params) == "string":
        params = json.decode(params)
    elif params == None and has_refresh_token:
        params = dict(
            client_id = TWITCH_CLIENT_ID,
            grant_type = "refresh_token",
            refresh_token = refresh_token,
        )

    # get a new token
    res = http.post(
        url = "https://id.twitch.tv/oauth2/token",
        headers = {
            "Accept": "application/json",
        },
        form_body = dict(
            params,
            client_secret = TWITCH_CLIENT_SECRET,
        ),
        form_encoding = "application/x-www-form-urlencoded",
    )

    if res.status_code != 200:
        fail("token request failed with status code: %d - %s" %
             (res.status_code, res.body()))

    token_params = res.json()
    access_token = token_params["access_token"]

    if not has_refresh_token:
        refresh_token = token_params["refresh_token"]

    # cache the access token so it can be reteived using the refresh token
    cache.set(refresh_token, access_token, ttl_seconds = int(token_params["expires_in"] - 30))

    return access_token if has_refresh_token else refresh_token

def get_schema():
    display_modes = [
        schema.Option(value = "followers", display = "Followers"),
        schema.Option(value = "subscribers", display = "Subscribers"),
    ]
    return schema.Schema(
        version = "1",
        fields = [
            schema.OAuth2(
                id = "auth",
                name = "Twitch",
                desc = "Connect your Twitch account.",
                icon = "twitch",
                handler = get_token,
                client_id = TWITCH_CLIENT_ID,
                authorization_endpoint = "https://id.twitch.tv/oauth2/authorize",
                scopes = [
                    "user:read:follows",
                    "user:read:subscriptions",
                    "channel:read:subscriptions",
                ],
            ),
            schema.Text(
                id = "username",
                icon = "user",
                name = "Username",
                desc = "The Twitch username to display stats for.",
                default = "ninja",
            ),
            schema.Dropdown(
                id = "display_mode",
                name = "Display",
                desc = "Choose what stat to show.",
                icon = "barsProgress",
                options = display_modes,
                default = display_modes[0].value,
            ),
            schema.Toggle(
                id = "show_username",
                name = "Show username",
                desc = "Whether to show the username below the stat.",
                icon = "eye",
                default = True,
            ),
        ],
    )
