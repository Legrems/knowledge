# How to use `explain` from sql in a Django queryset

```python
from django.db import connections
from django.db.models.query import QuerySet

class QuerySetExplainMixin:
    def explain(self):
        cursor = connections[self.db].cursor()
        query, params = self.query.sql_with_params()
        cursor.execute('explain %s' % query, params)
        return '\n'.join(r[0] for r in cursor.fetchall())

QuerySet.__bases__ += (QuerySetExplainMixin,)
```

## Usage
```python
print(MyModel.objects.filter(...).explain())
```

Source:
 - [Stack overflow: Easy way to run "explain" on query sets in django](https://stackoverflow.com/questions/11476664/easy-way-to-run-explain-on-query-sets-in-django)

```{tags} Django, Python, PostgreSQL, Explain, SQL, QuerySet, Debugging
```
