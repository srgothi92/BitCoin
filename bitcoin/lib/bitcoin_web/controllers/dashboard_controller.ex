defmodule BitcoinWeb.DashboardController do
  use BitcoinWeb, :controller


def dashboard(conn, params) do
  IO.inspect("abcdef")
  render(conn, "dashboard.html")
 end

end
