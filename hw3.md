# Part 1


## 1. Add a Done field
```rails generate migration AddDoneToTodos done:boolean```

Set Default to false:
- Add default: false
```add_column :todos, :done, :boolean, default: false```

Run ```rails db:migrate```

Update Todo params in Todo Controller to expect Done value

Added checkbox in the form to set Done status:
```
<div>
    <%= form.label :done, style: "display: block" %>
    <%= form.check_box :done %>
</div>
```

Update Todo partial to show done status:
```
<div>
    <strong>Done:</strong>
    <%= todo.done? ? "Yes" : "No" %>
</div>
```

## 2. Add a custom route named ```new_todo```
