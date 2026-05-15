# Gitmoji

Gitmoji standardizes git commit messages around emoji. This reference follows the [gitmoji.dev](https://gitmoji.dev) spec by Carlos Cuesta, sourced from [gitmojis.json](https://github.com/carloscuesta/gitmoji/blob/master/packages/gitmojis/src/gitmojis.json).

## Format

```
<gitmoji> [(scope)] <message>

[body]
```

- gitmoji: unicode emoji expressing the type of change (see table below)
- scope: optional context for the change area in parentheses
- message: brief summary, capitalized, imperative present tense
- body: optional free-form details, wrapped at 72 characters

## Emoji table

| Emoji | Code | Description |
|-------|------|-------------|
| 🎨 | `:art:` | Improve structure / format of the code. |
| ⚡️ | `:zap:` | Improve performance. |
| 🔥 | `:fire:` | Remove code or files. |
| 🐛 | `:bug:` | Fix a bug. |
| 🚑️ | `:ambulance:` | Critical hotfix. |
| ✨ | `:sparkles:` | Introduce new features. |
| 📝 | `:memo:` | Add or update documentation. |
| 🚀 | `:rocket:` | Deploy stuff. |
| 💄 | `:lipstick:` | Add or update the UI and style files. |
| 🎉 | `:tada:` | Begin a project. |
| ✅ | `:white_check_mark:` | Add, update, or pass tests. |
| 🔒️ | `:lock:` | Fix security or privacy issues. |
| 🔐 | `:closed_lock_with_key:` | Add or update secrets. |
| 🔖 | `:bookmark:` | Release / Version tags. |
| 🚨 | `:rotating_light:` | Fix compiler / linter warnings. |
| 🚧 | `:construction:` | Work in progress. |
| 💚 | `:green_heart:` | Fix CI Build. |
| ⬇️ | `:arrow_down:` | Downgrade dependencies. |
| ⬆️ | `:arrow_up:` | Upgrade dependencies. |
| 📌 | `:pushpin:` | Pin dependencies to specific versions. |
| 👷 | `:construction_worker:` | Add or update CI build system. |
| 📈 | `:chart_with_upwards_trend:` | Add or update analytics or track code. |
| ♻️ | `:recycle:` | Refactor code. |
| ➕ | `:heavy_plus_sign:` | Add a dependency. |
| ➖ | `:heavy_minus_sign:` | Remove a dependency. |
| 🔧 | `:wrench:` | Add or update configuration files. |
| 🔨 | `:hammer:` | Add or update development scripts. |
| 🌐 | `:globe_with_meridians:` | Internationalization and localization. |
| ✏️ | `:pencil2:` | Fix typos. |
| 💩 | `:poop:` | Write bad code that needs to be improved. |
| ⏪️ | `:rewind:` | Revert changes. |
| 🔀 | `:twisted_rightwards_arrows:` | Merge branches. |
| 📦️ | `:package:` | Add or update compiled files or packages. |
| 👽️ | `:alien:` | Update code due to external API changes. |
| 🚚 | `:truck:` | Move or rename resources (e.g.: files, paths, routes). |
| 📄 | `:page_facing_up:` | Add or update license. |
| 💥 | `:boom:` | Introduce breaking changes. |
| 🍱 | `:bento:` | Add or update assets. |
| ♿️ | `:wheelchair:` | Improve accessibility. |
| 💡 | `:bulb:` | Add or update comments in source code. |
| 🍻 | `:beers:` | Write code drunkenly. |
| 💬 | `:speech_balloon:` | Add or update text and literals. |
| 🗃️ | `:card_file_box:` | Perform database related changes. |
| 🔊 | `:loud_sound:` | Add or update logs. |
| 🔇 | `:mute:` | Remove logs. |
| 👥 | `:busts_in_silhouette:` | Add or update contributor(s). |
| 🚸 | `:children_crossing:` | Improve user experience / usability. |
| 🏗️ | `:building_construction:` | Make architectural changes. |
| 📱 | `:iphone:` | Work on responsive design. |
| 🤡 | `:clown_face:` | Mock things. |
| 🥚 | `:egg:` | Add or update an easter egg. |
| 🙈 | `:see_no_evil:` | Add or update a .gitignore file. |
| 📸 | `:camera_flash:` | Add or update snapshots. |
| ⚗️ | `:alembic:` | Perform experiments. |
| 🔍️ | `:mag:` | Improve SEO. |
| 🏷️ | `:label:` | Add or update types. |
| 🌱 | `:seedling:` | Add or update seed files. |
| 🚩 | `:triangular_flag_on_post:` | Add, update, or remove feature flags. |
| 🥅 | `:goal_net:` | Catch errors. |
| 💫 | `:dizzy:` | Add or update animations and transitions. |
| 🗑️ | `:wastebasket:` | Deprecate code that needs to be cleaned up. |
| 🛂 | `:passport_control:` | Work on code related to authorization, roles and permissions. |
| 🩹 | `:adhesive_bandage:` | Simple fix for a non-critical issue. |
| 🧐 | `:monocle_face:` | Data exploration/inspection. |
| ⚰️ | `:coffin:` | Remove dead code. |
| 🧪 | `:test_tube:` | Add a failing test. |
| 👔 | `:necktie:` | Add or update business logic. |
| 🩺 | `:stethoscope:` | Add or update healthcheck. |
| 🧱 | `:bricks:` | Infrastructure related changes. |
| 🧑‍💻 | `:technologist:` | Improve developer experience. |
| 💸 | `:money_with_wings:` | Add sponsorships or money related infrastructure. |
| 🧵 | `:thread:` | Add or update code related to multithreading or concurrency. |
| 🦺 | `:safety_vest:` | Add or update code related to validation. |
| ✈️ | `:airplane:` | Improve offline experience. |
| 🦖 | `:t-rex:` | Add backwards compatibility. |

## Choosing an emoji

### Single intent

Match your change to a single emoji using the description column above. When one intent is clear, use it directly:

- Fixed a runtime crash → 🐛
- Removed dead code paths → 🔥 or ⚰️
- Reformatted entire file → 🎨
- Added input validation → 🦺

### Multiple intents

When a commit spans multiple types of change, pick the emoji that best represents the primary purpose:

| Scenario | Primary emoji | Secondary in body |
|----------|--------------|-------------------|
| Bug fix + refactor | 🐛 (bug was the driver) | mention refactor in body |
| Refactor + docs update | ♻️ (structural change) | mention docs in body |
| Feature + its tests | ✨ (feature) | mention tests in body |
| Config + dep upgrade | Separate commits preferred. Combine only if tightly coupled — use ⬆️ for deps, 🔧 for config |
| Fix + docs + tests | Separate commits preferred. Combine only if trivial — use the fix emoji |

Rule of thumb: prefer atomic commits. If changes would benefit from separate review or have different scope, split them.

## Examples

```
✨ Add user registration endpoint

♻️ (api) Extract pagination helper

🐛 Fix null pointer in session handler

session.token was not checked before dereference.
Add guard clause and log warning on missing token.

📝 (api) Document rate limiting behavior
```
