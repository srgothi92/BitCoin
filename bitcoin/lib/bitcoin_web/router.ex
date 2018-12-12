defmodule BitcoinWeb.Router do
  use BitcoinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BitcoinWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/su", DashboardController, :dashboard
    get "/getAllBalance", DashboardController, :getAllBalance
    get "/getTransactionCount", DashboardController, :getTransactionCount
    get "/getBlockCount", DashboardController, :getBlockCount
    get "/startSimulation", DashboardController, :startSimulation
    get "/stopSimulation", DashboardController, :stopSimulation
    get "/getTransactionCount", DashboardController, :getTransactionCount
    get "/getBlockCount", DashboardController, :getBlockCount
  end

  # Other scopes may use custom stacks.
  # scope "/api", BitcoinWeb do
  #   pipe_through :api
  # end
end
