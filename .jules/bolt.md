## 2024-07-25 - Global Loading State Inefficiency

**Learning:** The application's `MealsBloc` uses a global `MealOperationInProgress` state that triggers a full-screen loading indicator and rebuilds the entire `ListView` during individual meal operations (e.g., complete, skip). This blocks all UI interaction and creates a disruptive user experience, which is inefficient for localized updates.

**Action:** When a full refactor to component-level state management is not feasible, use `BlocBuilder`'s `buildWhen` property to prevent the UI from rebuilding during intermediate global loading states. This preserves UI interactivity and avoids unnecessary re-renders while still allowing for a global success/error state to be shown.
