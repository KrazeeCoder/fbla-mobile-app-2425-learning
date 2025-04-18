# ShowcaseService Documentation

This service provides a simple and clean way to manage showcase tooltips throughout the app, using the `showcaseview` package.

## Setup

The ShowcaseService is already set up in the app's main.dart file using Provider. There's no additional setup required.

## Usage

### Starting a pre-defined showcase

The ShowcaseService provides methods for starting pre-defined showcases for different screens:

```dart
// Using context.read extension (requires Provider package)
context.read<ShowcaseService>().startHomeScreenShowcase(context);
context.read<ShowcaseService>().startLearnScreenShowcase(context);
```

### Starting a custom showcase

You can also start a custom showcase with any list of GlobalKeys:

```dart
// Using the static method
ShowcaseService.startCustomShowcase(
  context, 
  [ShowcaseKeys.keyOne, ShowcaseKeys.keyTwo, ShowcaseKeys.keyThree]
);
```

### Chaining showcases

To chain showcases (start a new one after the previous one completes), use the `onTargetClick` and `disposeOnTap` properties of the Showcase widget:

```dart
Showcase(
  key: ShowcaseKeys.someKey,
  title: 'Title',
  description: 'Description',
  onTargetClick: () {
    // Navigate to another screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => AnotherScreen()));
    
    // Start a new showcase on that screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowcaseService>().startAnotherScreenShowcase(context);
    });
  },
  disposeOnTap: true, // Important: this dismisses the current showcase
  child: YourWidget(),
)
```

### Tracking completion status

The ShowcaseService tracks whether the user has completed the initial showcase:

```dart
final hasCompleted = context.read<ShowcaseService>().hasCompletedInitialShowcase;

// You can also listen for changes
Consumer<ShowcaseService>(
  builder: (context, service, child) {
    return Text('Completed: ${service.hasCompletedInitialShowcase}');
  }
)
```

### Resetting showcase (for testing)

For testing purposes, you can reset the showcase:

```dart
context.read<ShowcaseService>().resetShowcase();
```

## Available Keys

All showcase keys are defined in the `ShowcaseKeys` class. This class provides both individual keys and methods to get groups of keys for different showcase sequences:

```dart
// Individual keys
ShowcaseKeys.helpIconKey
ShowcaseKeys.learnNavKey
// etc.

// Groups of keys
ShowcaseKeys.getFirstShowcaseKeys()
ShowcaseKeys.getSecondShowcaseKeys()
// etc.
``` 