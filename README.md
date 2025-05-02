# Presentation

The Trinity project provides a modern, responsive e-commerce mobile application and a desktop inventory management interface.

The goal of this project is to simulate a product usable by a large retail store.

By following the steps in this guide, you can easily install and run the project to test its features.

## Step 1: Set up the environment

```bash
cp .env.demo .env
```

## Step 2: Start Docker services

To ensure the application works correctly, you need to start the backend services via Docker:

```bash
# Start Docker containers at the project root
docker-compose up -d
```

This will launch all necessary services (API, database, etc.) in the background.

## Step 3: Navigate to the "mobile" folder

## Step 4: Install dependencies

```bash
flutter pub get
```

## Step 5: Launch the project

Ensure your simulator is connected, then launch the application with the command:

```bash
flutter run -d <remote or USB device>
```

## Developer Notes

> Note
>
> Due to our complex deeplink system, the **payment module** only works on a real device.
> We recommend setting up a wireless connection with Xcode for an optimal experience.
