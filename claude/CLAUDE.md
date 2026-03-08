# Project Conventions

## Credentials & Environment Variables
- Always use `.env` files for API keys and credentials — never export them in the command line.
- Load environment variables from `.env` using `python-dotenv` (Python) or equivalent for other languages.
- Never commit `.env` files to version control.
