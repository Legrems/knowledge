# List all related model in Django

Using NestedObjects from Django's admin utils, you can collect all related objects of a model instance.
Could be usefull to check for related objects before deleting a model instance or for exporting related data.

```python
from django.contrib.admin.utils import NestedObjects

collector = NestedObjects(using="default")
collector.collect([MyModel.objects.get(pk=123456)])
```

`collector.data` is a dictionary where the keys are the model classes and the values are lists of objects of that class. You can iterate over it to access all related objects.

```python
for model, related_objects in collector.data.items():
    print(f"Model: {model.__name__}, Related Objects count: {len(related_objects)}")
```

## Get a flat list of all related objects
Utilizing `itertools.chain`, you can flatten the list of related objects into a single list:

```python
from itertools import chain

objects = list(chain.from_iterable(collector.data.values()))
```

## Exporting related models in JSON format
We could also serialize the objects to JSON format for export for later analysis or backup (don't use this in production as it can be slow for large datasets):
```python
from django.core import serializers

with open("export.json", "w") as f:
    f.write(serializers.serialize("json", objects))
```

Source:
 - [Django `NestedObjects`](https://github.com/django/django/blob/dca8284a376128c64bd0e0792ad12391ae3e7202/django/contrib/admin/utils.py#L186)

```{tags} Django, Python, JSON, Export, Related model, itertools, NestedObjects, Serialization, from_iterable
```
