# Budget Bites Architecture

## Architecture Overview

Budget Bites is a Flutter mobile application developed using Dart. The project is organized into separate folders for screens, models, database operations, and services. This structure helps keep the user interface, stored data, and application logic organized.

The screens handle user interactions and display information. The models represent meals and purchase records, while the database helper manages storing, retrieving, updating, and deleting information using SQLite. The services folder contains the Lunch Lens prediction logic, which uses previous purchase prices to estimate future meal costs.

The app also uses SharedPreferences to store the user's budget preference and light/dark mode setting.

## Project Structure

The lib folder contains the main Dart files for Budget Bites. The project is organized into the following parts:

- main.dart - Starts the application.
- database/ - Contains database_helper.dart, which handles SQLite operations.
- models/ - Contains meal.dart and purchase_log.dart, which represent the app's data.
- screens/ - Contains the different screens users interact with.
- services/ - Contains lunch_lens_predictor.dart, which handles the Lunch Lens prediction logic.

## How the Components Work Together

When a user interacts with Budget Bites, the screens handle their actions and display the results. For example, when a user adds a meal, the meal form collects the information, creates a Meal object, and uses DatabaseHelper to save it in SQLite.

When the user opens the Dashboard, the app retrieves the saved meals from the database and displays them. Purchase History works similarly by retrieving and managing purchase records.

Lunch Lens uses previous purchase records to estimate future meal prices. The prediction logic is kept in a separate service instead of being part of the database helper.

The Settings screen manages the user's budget preference and theme setting, which are saved using SharedPreferences.

## Database Design

Budget Bites uses SQLite (sqflite) to store meals and purchase history locally. The database is named `budget_bites.db` and uses version 2.

The database contains two tables:

**1. meals**

This table stores information about each meal, including:

- `id` - Unique ID for each meal (primary key).
- `name` - Name of the meal.
- `cuisine` - Cuisine category.
- `venue` - Where the meal is from.
- `estimated_price` - Estimated cost of the meal.

**2. purchase_logs**

This table stores food purchase records, including:

- `id` - Unique ID for each purchase (primary key).
- `mealId` - ID of the meal associated with the purchase.
- `purchasedAt` - Date and time of the purchase.
- `actualPriceMinor` - Actual purchase price stored in cents.

The two tables are connected through `mealId`, which references the `id` column in the meals table. This allows one meal to have multiple purchase records.

When a meal is deleted, the database helper uses a transaction to delete its associated purchase records before removing the meal itself.

## Lunch Lens Prediction Logic

Lunch Lens is a rule-based price prediction feature that uses previous purchase records to estimate how much a meal might cost.

The prediction logic is stored in `lunch_lens_predictor.dart`, keeping it separate from the screens and database operations.

Lunch Lens follows these rules:

- It uses the three most recent purchase prices for the selected meal.
- If there are at least three purchases, it calculates their average to predict the next price.
- If there are fewer than three purchases, it does not generate a prediction.
- It compares the predicted price with the user's saved budget to determine whether the meal is within budget.
- Predictions are recalculated when purchase history changes.

Lunch Lens runs locally and does not require an internet connection or an external AI service.