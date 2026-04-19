# Part 1

## 1. Add a Done field

### Files changed
- `db/migrate/20260419210535_add_done_to_todos.rb` (new)
- `db/schema.rb` (auto-updated by `db:migrate`)
- `app/controllers/todos_controller.rb`
- `app/views/todos/_form.html.erb`
- `app/views/todos/_todo.html.erb`

### Steps & code

**Generate the migration:**
```
rails generate migration AddDoneToTodos done:boolean
```

**Set the default to `false`** in `db/migrate/20260419210535_add_done_to_todos.rb`:
```ruby
class AddDoneToTodos < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :done, :boolean, default: false
  end
end
```

**Run the migration:**
```
rails db:migrate
```

**Permit `done` in strong params** in `app/controllers/todos_controller.rb`:
```ruby
def todo_params
  params.expect(todo: [ :description, :done ])
end
```

**Add checkbox to the form** in `app/views/todos/_form.html.erb`:
```erb
<div>
  <%= form.label :done, style: "display: block" %>
  <%= form.check_box :done %>
</div>
```

**Show done status in the partial** in `app/views/todos/_todo.html.erb`:
```erb
<div>
  <strong>Done:</strong>
  <%= todo.done? ? "Yes" : "No" %>
</div>
```

---

## 2. Add a custom route named `new_todo`

### Files changed
- `config/routes.rb`

### Steps & code

Added a custom `get` route with the helper name `new_todo`, and excluded the default `:new` route from `resources :todos` so the helper name doesn't collide.

In `config/routes.rb`:
```ruby
  # add a new route new_todo
  get "new_todo", to: "todos#new", as: :new_todo
```

- `resources :todos, except: [:new]` — prevents Rails from auto-creating the default `GET /todos/new` route, which otherwise reserves the `new_todo_path` helper name.
- `get "new_todo", to: "todos#new", as: :new_todo` — defines the URL `/new_todo`, routes it to `TodosController#new`, and creates the helper `new_todo_path`.

### Verify
```
rails routes -g new_todo
```
Should show:
```
new_todo GET /new_todo(.:format) todos#new
```

---

## 3. Set the homepage

### Files changed
- `config/routes.rb`

### Steps & code

Added a `root` route so visiting `/` renders the todos index page instead of the default Rails welcome page.

In `config/routes.rb`:
```ruby
root "todos#index"
```

- `root` is Rails' special helper for the `/` URL.
- `"todos#index"` tells Rails to run the `index` action of `TodosController` when someone visits `/`.

### Verify
```
rails routes -g root
```
Should show:
```
root GET /  todos#index
```
Visiting `http://localhost:3000/` in the browser now renders the todos index page.

---

# Part 2 — Deploy to Heroku

## Split database gems by environment

### Files changed
- `Gemfile`
- `Gemfile.lock` (auto-updated by `bundle install`)

**Added a new `:production` group** at the bottom of `Gemfile`:
```ruby
group :production do
  # Use PostgreSQL as the database for Active Record (production only, for Heroku)
  gem "pg", "~> 1.1"
end
```

**Ran `bundle install`** to update `Gemfile.lock` with the `pg` gem.

## Update `config/database.yml` for Postgres in production

### Files changed
- `config/database.yml`

### Why
The production block was hardcoded to SQLite, which would crash on Heroku (sqlite3 gem is no longer in production, and Heroku's filesystem is ephemeral). Rails 8 also uses four logical databases in production (primary, cache, queue, cable) for Solid Cache/Queue/Cable. Heroku's `essential-0` plan gives one Postgres DB, so all four point at the same `DATABASE_URL`.

### Change
Replaced the production block so it uses `adapter: postgresql` and reads Heroku's `DATABASE_URL`:
```yaml
production:
  primary: &primary_production
    adapter: postgresql
    url: <%= ENV["DATABASE_URL"] %>
  cache:
    <<: *primary_production
    migrations_paths: db/cache_migrate
  queue:
    <<: *primary_production
    migrations_paths: db/queue_migrate
  cable:
    <<: *primary_production
    migrations_paths: db/cable_migrate
```
Development and test still use SQLite — unchanged.



