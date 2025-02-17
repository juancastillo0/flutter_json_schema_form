import 'package:flutter/material.dart';
import 'package:flutter_json_schema_form/controller/flutter_json_schema_form_controller.dart';
import 'package:flutter_json_schema_form/widgets/flutter_json_schema_field.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_json_schema_form/flutter_json_schema_form.dart';
import 'package:json_schema_document/json_schema_document.dart';

void main() {
  // Should render title
  testWidgets(
    'Should render title',
    (WidgetTester tester) async {
      final jsonSchema = JsonSchema.fromMap(
        {
          "type": "object",
          "title": "Login",
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterJsonSchemaForm(
              controller: FlutterJsonSchemaFormController(
                jsonSchema: jsonSchema,
              ),
              jsonSchema: jsonSchema,
              path: [],
            ),
          ),
        ),
      );
      expect(find.text('Login'), findsOneWidget);
    },
  );

  // Should render description
  testWidgets('Should render description', (WidgetTester tester) async {
    final jsonSchema = JsonSchema.fromMap(
      {
        "type": "object",
        "title": "Login",
        "description": "Login to the system",
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterJsonSchemaForm(
            controller: FlutterJsonSchemaFormController(
              jsonSchema: jsonSchema,
            ),
            jsonSchema: jsonSchema,
            path: [],
          ),
        ),
      ),
    );
    expect(find.text('Login to the system'), findsOneWidget);
  });

  // Should render properties as TextFields

  group('Should render properties as FlutterJsonSchemaFormField', () {
    testWidgets(
        'With two properties should render two FlutterJsonSchemaFormField',
        (WidgetTester tester) async {
      final jsonSchema = JsonSchema.fromMap(
        {
          "type": "object",
          "title": "Login",
          "properties": {
            "username": {
              "type": "string",
              "title": "Username",
            },
            "password": {
              "type": "string",
              "title": "Password",
            },
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterJsonSchemaForm(
              controller: FlutterJsonSchemaFormController(
                jsonSchema: jsonSchema,
              ),
              jsonSchema: jsonSchema,
              path: [],
            ),
          ),
        ),
      );
      expect(find.byType(FlutterJsonSchemaFormField), findsNWidgets(2));
    });
  });

  // FlutterJsonSchemaForm + controllers test
  group('FlutterJsonSchemaForm + controllers test', () {
    testWidgets(
        'TextFields should be controllable by FlutterJsonSchemaFormController',
        (WidgetTester tester) async {
      final jsonSchema = JsonSchema.fromMap(
        {
          "type": "object",
          "title": "Login",
          "properties": {
            "username": {
              "type": "string",
              "title": "Username",
            },
            "password": {
              "type": "string",
              "title": "Password",
            },
          },
        },
      );

      final controller = FlutterJsonSchemaFormController(
        jsonSchema: jsonSchema,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterJsonSchemaForm(
              controller: controller,
              path: [],
              jsonSchema: jsonSchema,
            ),
          ),
        ),
      );

      final usernameController = controller
          .textEditingControllerMapping['username'] as TextEditingController;

      usernameController.value = const TextEditingValue(
        text: 'User',
        selection: TextSelection.collapsed(offset: 5),
      );

      await tester.pumpAndSettle();

      expect(find.text('User'), findsOneWidget);
    });

    // TextFields should be controllable by the setData method
    testWidgets(
      "TextFields should be controllable by the setData method",
      (WidgetTester tester) async {
        final jsonSchema = JsonSchema.fromMap(
          {
            "type": "object",
            "title": "Login",
            "properties": {
              "username": {
                "type": "string",
                "title": "Username",
              },
              "password": {
                "type": "string",
                "title": "Password",
              },
            },
          },
        );

        final controller = FlutterJsonSchemaFormController(
          jsonSchema: jsonSchema,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterJsonSchemaForm(
                controller: controller,
                path: [],
                jsonSchema: jsonSchema,
              ),
            ),
          ),
        );

        controller.setData({
          'username': 'Elias',
          'password': '123',
        });

        await tester.pumpAndSettle();

        expect(find.text('Elias'), findsOneWidget);
      },
    );
  });

  group("test disable property", () {
    testWidgets(
      "If disabled property is true, all TextField should be disabled",
      (WidgetTester tester) async {
        final jsonSchema = JsonSchema.fromMap(
          {
            "type": "object",
            "title": "Login",
            "properties": {
              "username": {
                "type": "string",
                "title": "Username",
              },
              "password": {
                "type": "string",
                "title": "Password",
              },
            },
          },
        );

        final controller = FlutterJsonSchemaFormController(
          jsonSchema: jsonSchema,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterJsonSchemaForm(
                controller: controller,
                path: [],
                jsonSchema: jsonSchema,
                disabled: true,
              ),
            ),
          ),
        );

        final finder = find.byType(FlutterJsonSchemaFormField);
        final listOfWidgets = finder.evaluate().toList();
        final forceDisabledProps = listOfWidgets.map((element) {
          return (element.widget as FlutterJsonSchemaFormField).forceDisabled;
        }).toList();
        final isAllDisabled =
            forceDisabledProps.every((element) => element == true);
        expect(isAllDisabled, true);
      },
    );

    testWidgets(
      "If disabled property is false, all TextField should follow the schema",
      (WidgetTester tester) async {
        final jsonSchema = JsonSchema.fromMap(
          {
            "type": "object",
            "title": "Login",
            "properties": {
              "username": {
                "type": "string",
                "title": "Username",
                "readOnly": true,
              },
              "password": {
                "type": "string",
                "title": "Password",
              },
            },
          },
        );

        final controller = FlutterJsonSchemaFormController(
          jsonSchema: jsonSchema,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterJsonSchemaForm(
                controller: controller,
                path: [],
                jsonSchema: jsonSchema,
              ),
            ),
          ),
        );

        final finder = find.byType(FlutterJsonSchemaFormField);
        final listOfWidgets = finder.evaluate().toList();
        final forceDisabledProps = listOfWidgets.map((element) {
          return (element.widget as FlutterJsonSchemaFormField).forceDisabled;
        }).toList();
        final isntAllDisabled =
            forceDisabledProps.every((element) => element == false);
        expect(isntAllDisabled, true);
      },
    );
  });
}
