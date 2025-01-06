# Kolector - Modern Credit Recovery Application

Kolector is a Django-based backend application designed for efficient credit recovery. This application allows agencies and clients to manage accounts, consumers, and financial balances with advanced features such as data import via CSV files, API endpoints for account management, and secure database handling.

---

## Features

- **Account Management**: Track balances, statuses, and consumer details for accounts.
- **API Integration**: RESTful API endpoints for fetching, filtering, and managing account data.
- **CSV Import**: Upload bulk account and consumer data using CSV files.
- **Pagination**: Efficient data handling with paginated API responses.
- **Secure Authentication**: Ready to integrate with secure authentication mechanisms.
- **Scalable Database**: Uses PostgreSQL in production for reliability and performance.
- **Custom Commands**: Manage backend data with custom Django management commands.

---

## Prerequisites

- Python 3.11+
- Docker & Docker Compose
- PostgreSQL (for production)

---

## Installation

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/kolector.git
    cd kolector
    ```

2. **Set Up Virtual Environment (Optional)**:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    ```

3. **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

4. **Set Up Environment Variables**:
    Create a `.env` file in the project root and add the following:
    ```env
    DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1
    POSTGRES_DB=kolector_db
    POSTGRES_USER=yourusername
    POSTGRES_PASSWORD=yourpassword
    POSTGRES_HOST=localhost
    POSTGRES_PORT=5432
    CORS_ALLOWED_ORIGINS=http://localhost:3000
    ```

5. **Run Migrations**:
    ```bash
    python manage.py migrate
    ```

6. **Run the Server**:
    ```bash
    python manage.py runserver
    ```
    Visit [http://localhost:8000](http://localhost:8000) to see the application.

---

## Using Docker

1. **Build and Start Containers**:
    ```bash
    docker-compose up --build
    ```

2. **Access the Application**:
    - Backend: [http://localhost:8000](http://localhost:8000)

---

## API Endpoints

### Account Management

1. **Get All Accounts**:
    ```http
    GET /accounts
    ```
    - **Query Parameters**:
        - `min_balance`: Filter accounts with a minimum balance.
        - `max_balance`: Filter accounts with a maximum balance.
        - `consumer_name`: Search by consumer name.
        - `status`: Filter by account status (`in_collection`, `collected`, `inactive`).

2. **Upload CSV**:
    ```http
    POST /upload-csv
    ```
    - **Body**: Upload a CSV file containing account and consumer data.

---

## Running Tests

1. **Run Unit Tests**:
    ```bash
    python manage.py test
    ```

---

## Custom Commands

1. **Load Data from CSV**:
    ```bash
    python manage.py load_csv path/to/file.csv
    ```
    - Automatically creates default agency and client entries if they don’t exist.

---

## Project Structure

```
kolector/
|-- collector/
|   |-- migrations/           # Database migrations
|   |-- models.py             # Database schema
|   |-- views.py              # API logic
|   |-- serializers.py        # Data serialization
|   |-- urls.py               # App-level URL routing
|   |-- management/           # Custom management commands
|-- kolector/
|   |-- settings/             # Environment-specific settings
|   |-- urls.py               # Project-level URL routing
|   |-- wsgi.py               # WSGI entry point
|-- Dockerfile                # Docker image configuration
|-- docker-compose.yml        # Docker services orchestration
|-- requirements.txt          # Python dependencies
```

---

## Future Enhancements

- Integration with third-party APIs for financial data.
- Advanced authentication and role-based access control.
- Frontend UI for non-technical users.
- Automated backups for critical data.

---

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Contact

For questions or support, contact [asommy@yahoo.com](mailto:asommy@yahoo.com).

