# Existence of key inside a nested json field in Django with PostgreSQL

When working with PostgreSQL and Django, you might need to check for the existence of a key inside a nested JSON field.
If the field is a list of dictionaries, you can't really use the `has_keys` method directly on the queryset, as it only works for a specific item in the list.
Instead, you can use the `jsonb_path_exists` function to check for the existence of a key across all items in the list.

```python
class MyModel(models.Model):
    data = models.JSONField()

mymodel.data = [{"settings": {"test": "value", ...}}, {...}, ...]
```

We can do: `MyModel.objects.filter(data__0__settings__has_keys=['test'])`, but this only work for the first item.


But we can use the `extra` method with a raw SQL query to achieve this.

```python
MyModel.objects.extra(where=[ "jsonb_path_exists(data, %s)" ], params=['$[*] ? (@.settings.test == "value")'])
```

And to check for the existence of a key without a specific value, you can use the same `jsonb_path_exists` function:

```python
MyModel.objects.extra(where=[ "jsonb_path_exists(data, %s)" ], params=["$[*] ? (exists(@.settings.test))"])
```


Also equivalent:

```python
from django.db.models import Func, BooleanField
from django.db.models import Value as V

class JSONBPathExists(Func):
     """A Django QuerySet Function expression for PostgreSQL's `jsonb_path_exists`."""
     function = "jsonb_path_exists"
     output_field = BooleanField()

MyModel.objects.filter(JSONBPathExists("data", V('$.** ? (@.settings.test == "test")')))
```

To check for the existence of a key without a specific value, you can use the same `JSONBPathExists` function:

```python
MyModel.objects.filter(JSONBPathExists("data", V('$.** ? (exists(@.settings.test))')))
```

As it's a bit verbose and not very readable, we can create custom functions to make it more convenient.

## Nested key value filtering
```python
from django.db.models import Func, BooleanField
from django.db.models import Value as V


class JBV(Func):
    """JBV: JsonB path Value."""

    function = "jsonb_path_exists"
    output_field = BooleanField()

    def __init__(self, field:str, key:str, value:str):
        """Key can be a nested key like 'settings.test'.

        Be aware that this will raise an error if the value is malformed and not valid for the SQL query."""
        v = V(f'$.** ? (@.{key} == "{value}")')

        super().__init__(field, v)
```

### Example usage
```python
MyModel.objects.filter(JBV('data', 'settings.test', 'value'))
```

## Nested key existence check
```python
from django.db.models import Func, BooleanField
from django.db.models import Value as V

class JBE(Func):
    """JBE: JsonB path Exists."""

    function = "jsonb_path_exists"
    output_field = BooleanField()

    def __init__(self, field:str, key:str):
        """Key can be a nested key like 'settings.test'.

        Be aware that this will raise an error if the value is malformed and not valid for the SQL query."""
        v = V(f'$.** ? (exists(@.{key}))')

        super().__init__(field, v)
```


### Example usage
```python
MyModel.objects.filter(JBE('data', 'settings.test'))
```


Source:
 - [Postgres functions json](https://www.postgresql.org/docs/current/functions-json.html)
 - [Django Querying jsonfield](https://docs.djangoproject.com/en/5.2/topics/db/queries/#querying-jsonfield)
 - [Stack overflow: Can I use a jsonpath predicate in a filter?](https://stackoverflow.com/questions/76257375/can-i-use-a-jsonpath-predicate-in-a-filter)


```{tags} Django, Python, PostgreSQL, SQL, JSONField, jsonb_path_exists, nested search
```
