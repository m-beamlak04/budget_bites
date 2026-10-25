# Lunch Lens - AI Feature Documentation

## Feature Overview

Lunch Lens is a rule-based price prediction feature in Budget Bites that helps users estimate how much a meal might cost based on their previous purchases.

Lunch Lens looks at how much the user previously paid for a meal, predicts how much it might cost next time, and checks whether that price fits within their saved budget.

Lunch Lens runs locally without requiring an internet connection or an external AI service. It does not use a trained machine learning model. Instead, it uses a simple averaging method based on previous purchase prices.

## Prediction Rules and Calculation

Lunch Lens uses the three most recent purchase prices for a selected meal to predict its next price.

The feature follows these rules:

- If a meal has no purchase history, Lunch Lens shows that no purchase history is available. If there are only one or two purchases, it shows the most recent purchase price as a baseline but does not generate a prediction until there are at least three purchases.
- Once a meal has at least three purchases, Lunch Lens calculates the average of the three most recent prices.
- The predicted price is compared with the user's saved budget to determine whether the meal is within budget (affordable or not).
- When a purchase is added, edited, or deleted, the prediction is updated using the latest purchase history.

**Example:**

Suppose a user purchased the same meal three times at these prices:

- First purchase: $9.00
- Second purchase: $12.00
- Third purchase: $15.00

Lunch Lens calculates the predicted price as:

(\$9.00 + \$12.00 + \$15.00) / 3 = \$12.00

If the user's saved budget is \$15.00, the predicted price of \$12.00 is within budget.

This prediction is only an estimate based on previous purchases. The actual price may be different, and users can choose to ignore the prediction since Lunch Lens only provides suggestions and does not make decisions for them.

## Testing Scenarios

Lunch Lens was tested using different purchase histories to check whether its predictions updated correctly.

- **No purchase history:** Verified that Lunch Lens shows a message when no previous purchases are available.
- **Fewer than three purchases:** Verified that the most recent purchase price is shown as a baseline without generating a prediction.
- **Three purchases:** Entered prices of \$9.00, \$12.00, and \$15.00 and verified that Lunch Lens predicted \$12.00.
- **Adding another purchase:** Added a purchase of \$14.50 and verified that the prediction updated to \$13.83 using the three most recent prices.
- **Editing and deleting purchases:** Verified that predictions update when existing purchase records are changed or removed.
- **Budget comparison:** Tested different budget settings to verify that Lunch Lens correctly identifies whether the predicted price is within budget.

These tests helped confirm that Lunch Lens follows its prediction rules and responds to changes in purchase history.

## Limitations

Lunch Lens has a few limitations because it uses a simple rule-based prediction method.

- Predictions are based only on the three most recent purchases of the selected meal.
- Lunch Lens needs at least three previous purchases before it can generate a prediction.
- It does not consider outside factors such as restaurant price changes, discounts, or taxes.
- The prediction may be less accurate if previous purchase prices vary significantly, such as when there is an unusually high or low price (an outlier).
- Lunch Lens does not use machine learning or automatically improve its prediction method over time.

Because of these limitations, Lunch Lens predictions should be treated as estimates rather than guaranteed prices. Users can still make their own purchasing decisions regardless of the prediction.