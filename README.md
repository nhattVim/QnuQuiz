# QnuQuiz

---

## ⚙️ Prerequisites

- Repo Members: run env.ps1 (Windows) or env.sh (Unix) and use the GitHub token shared by the repo owner to fetch environment files.

    ```powershell
    ### Windows
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    .\env-sync.ps1
    ```

    ```zsh
    ### Unix / Linux
    ./env-sync.sh
    ```

- Non-members: manually copy from example files to create .env (for backend, frontend) and appsettings.json (for backend.NET).
    ```
    backend/application.yaml → backend/src/main/resources/application.yaml
    ```

---
