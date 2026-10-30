# Budget Bites

## Team Roles

Budget Bites was developed as an individual project by me, Beamlak Mulugeta. I was responsible for planning, designing, implementing, testing, and documenting the application.

## Project Overview

Budget Bites is a mobile app designed to help college students manage their food spending while balancing school, work, and other responsibilities. With expenses such as housing, books, transportation, and food, keeping track of food purchases can be difficult, especially when working with a limited budget.

The app allows users to plan meals, track food purchases, manage their budget preferences, and view spending summaries to better understand how their spending decisions affect their budget. Although Budget Bites is mainly intended for college students, it can also be useful for anyone who wants to manage their food spending.

Budget Bites stores information locally, allowing users to use the app offline and keep their saved data even after closing and reopening it.

## Features

- **Dashboard:** View the meal catalog and filter meals by cuisine. Select a meal to open its details, where users can view and manage meal information.
- **Meal Plan:** Add meals to a plan, adjust quantities, and view estimated costs. Reset the plan or finish it by entering actual prices, which are saved to purchase history.
- **Purchase History:** View, add, edit, and delete food purchase records. Filter purchases by date and view total spending.
- **Lunch Lens:** Uses previous purchase prices to predict how much a meal might cost and compares the prediction with the user's saved budget.
- **Settings:** Adjust the budget preference using a slider and switch between light and dark mode.

## Technologies Used

- **Flutter 3.47.2:** Used to build the app's user interface and screens.
- **Dart 3.13.2:** The programming language used to develop the app.
- **SQLite (sqflite):** Used to store meals and purchase history locally in two related database tables.
- **SharedPreferences:** Used to save the user's budget preference and light/dark mode setting.

## Setup and Run Instructions

1. Install Flutter and set up an Android emulator or connect an Android device.
2. Clone the Budget Bites GitHub repository.
3. Open the project folder in IntelliJ IDEA, Android Studio, or VS Code.
4. Open a terminal in the project directory and run `flutter pub get` to install the dependencies.
5. Start the Android emulator or connect an Android device.
6. Run `flutter run` to launch the app.

Budget Bites stores its data locally, so an internet connection is not required to use the app after installation.

## Data Storage

Budget Bites uses SQLite to store meal information and purchase history locally.

The SQLite database uses version 2 and contains the following tables:

- **meals:** Stores the meal ID, name, cuisine, venue, and estimated price.
- **purchase_logs:** Stores the purchase ID, associated meal ID, purchase date/time, and actual price in cents.

The `mealId` column in `purchase_logs` references the `id` column in `meals`, allowing one meal to have multiple purchase records. When a meal is deleted, its associated purchase logs are also removed.

The app also uses SharedPreferences to save the user's budget preference and light/dark mode setting.

Because the data is stored locally, users can access their saved meals, purchases, and settings without an internet connection. The information also remains available after closing and reopening the app.

## Testing

Budget Bites was tested on two Android emulators: Pixel 10 and Pixel 4.

The following areas were tested:

- Adding, editing, and deleting meals and purchase records.
- Creating, finishing, and resetting meal plans.
- Lunch Lens price predictions and budget comparisons.
- Saving and restoring data after closing and reopening the app.
- Using the app offline without an internet connection.
- Deleting meals and verifying that their associated purchase records are removed.
- Landscape layouts and larger font sizes.
- Budget and theme settings persistence.

The project was also checked using `flutter analyze`, which reported no issues.

## Known Issues and Future Enhancements

**Known Issues**

- No major issues were found during final testing on the two Android emulators.

**Future Enhancements**

- Allow users to set different budgets for individual days or weeks.
- Add charts to help users visualize their food spending over time.
- Improve Lunch Lens with more advanced prediction methods as more purchase history becomes available.
- Add an option to export purchase history for personal recordkeeping.

## Project Documentation

Additional documentation for Budget Bites includes:

- **ARCHITECTURE.md:** Explains the app's structure, database design, and how the different components work together.
- **AI_FEATURE.md:** Explains how Lunch Lens predicts meal prices, including its rules, testing scenarios, and limitations.
- **AI_Usage_Log.md:** Documents how AI tools were used during the project.
- **PROJECT_REPORT.pdf:** Covers the development process, testing, challenges, and project reflection.
- **Kanban_Contribution_Evidence.pdf:** Contains ClickUp progress snapshots and evidence of project development.
  - ClickUP Public Access URL: https://sharing.clickup.com/90141772401/b/h/6-901422326416-2/262afde69ee42bf

## License

Budget Bites was developed as an individual academic project for the Mobile Development course at Georgia State University. No open-source license has been assigned to this project.