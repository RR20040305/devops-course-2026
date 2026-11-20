FROM python:3.12-slim

# Создаем системного пользователя
RUN useradd --system --no-create-home app

WORKDIR /app

# Сначала копируем только зависимости (для кэширования)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY app.py .

# Переключаемся на непривилегированного пользователя
USER app

EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

