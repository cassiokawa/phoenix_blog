defmodule Blog.SessionController do
  use Blog.Web, :controller
	plug :scrub_params, "user" when action in [:create]

  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Blog.User

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    Repo.get_by(User, username: user_params["username"])
    |> sign_in(user_params["password"], conn)
  end

  defp sign_in(user, password, conn) when is_nil(user) do
	  conn
	  |> put_flash(:error, "Invalid username/password combination!")
	  |> redirect(to: page_path(conn, :index))
  end
  
  defp sign_in(user, password, conn) do
	  if checkpw(password, user.password_digest) do
	    conn
	    |> put_session(:current_user, %{id: user.id, username: user.username})
	    |> put_flash(:info, "Sign in successful!")
	    |> redirect(to: page_path(conn, :index))
	  else
	    conn
	    |> put_session(:current_user, nil)
	    |> put_flash(:error, "Invalid username/password combination!")
	    |> redirect(to: page_path(conn, :index))
	  end
  end

  def delete(conn, _params) do
	  conn
	  |> delete_session(:current_user)
	  |> put_flash(:info, "Signed out successfully!")
	  |> redirect(to: page_path(conn, :index))
  end

end