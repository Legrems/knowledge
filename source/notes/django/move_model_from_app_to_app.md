# Safely move a model between apps

1. Move the model class into the new app

For example, moving `MyClass` from `old_app.models` to `new_app.models`.

```{code-block} python
:caption: new_app/models.py
:linenos:

class MyClass(models.Model):
    # your fields here
    ...

    class Meta:
        db_table = "old_app_myclass"  # keep the same table name as before!
```

👉 This ensures the new model points to the existing table, not a new one.

2. Create a manual migration in the new app

Run: `python manage.py makemigrations new_app`

This will likely create a CreateModel migration. Edit it manually to use `migrations.SeparateDatabaseAndState`, which lets you tell Django “don’t touch the DB table, only update Django’s state.”

```{code-block} python
:caption: new_app/migrations/0001_initial.py
:linenos:

from django.db import migrations, models

class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("old_app", "XXXX_previous_migration"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            state_operations=[
                # Take the migrations.CreateModel from the auto-generated migration!
                migrations.CreateModel(
                    name="MyClass",
                    fields=[
                        ...
                    ],
                    options={"db_table": "old_app_myclass"},
                ),
            ],
            database_operations=[],
        ),
    ]
```

👉 This way, Django updates its model state but doesn’t actually create/drop the table.

3. Remove the model from the old app

Delete it from `old_app/models.py`.

Then run: `python manage.py makemigrations old_app`

That will generate a DeleteModel. Edit it manually so it only removes the model from Django’s state, not the DB:

```{code-block} python
:caption: old_app/migrations/XXXX_remove_myclass.py
:linenos:

from django.db import migrations

class Migration(migrations.Migration):

    dependencies = [
        ("old_app", "XXXX_previous_migration"),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            state_operations=[
                # Take the migrations.DeleteModel from the auto-generated migration!
                migrations.DeleteModel(name="MyClass"),
            ],
            database_operations=[],
        ),
    ]
```

4. Remove the `db_table` in `new_app/models.py`

```{code-block} python
:caption: new_app/models.py
:linenos:

class MyClass(models.Model):
    # your fields here
    ...

    # class Meta: <-- remove!
    #    db_table = "old_app_myclass" <-- remove!
```

5. Create auto migrations: `python manage.py makemigrations new_app`

This will generate a migrations to update the `db_table` on the `MyClass` model in `new_app` to use the default one (instead of the `old_app_myclass`)

6. Apply migrations
`python manage.py migrate`


Now:
 - Django knows the model is in the new app.
 - The db_table has been updated, and all the relation also
 - The default DB table from django is used
 - No data is lost. 🎉

```{tags} Django, Python, Model, App, Move, Data, db_table
```
