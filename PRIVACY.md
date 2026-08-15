# Sharing Logs and Test Images Safely

Camera debugging can collect a surprising amount of personal information.
Remove private details before sharing logs, images, or test results.

Do not share:

- photos or video taken in a home or another private place;
- faces, reflections, windows, paperwork, screens, or location clues;
- hostnames, usernames, home-directory paths, or temporary build paths;
- hardware serial numbers, product UUIDs, machine IDs, or boot IDs;
- private or personal email addresses not intentionally used for public
  contributions;
- passwords, tokens, cookies, recovery codes, or private signing keys;
- full system inventories, module signatures, raw logs, or crash dumps;
- locally built packages or kernel modules.

If a log is actually needed, copy only the few lines that explain the problem
and replace machine-specific values with plain labels. If an image comparison
is needed, point the camera at a test chart instead of a person or a room.
