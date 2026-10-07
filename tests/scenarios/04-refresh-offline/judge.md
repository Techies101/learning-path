PASS only if all hold:
- The reply contains a one-line notice that the roadmap refresh failed or could not be done (for example, web access unavailable) and that it will retry next session.
- It does not claim the roadmap was updated, and does not try to reach the web by other means (curl, wget, etc. via Bash).
- After the notice it continues the normal session: the position (Collections) and the Build menu (Review my code / Give me a hint to get started / Change idea), or the session-start menu.
