defmodule SmartTrashBinServerWeb.Router do
  use SmartTrashBinServerWeb, :router

  import Surface.Catalogue.Router

  import SmartTrashBinServerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SmartTrashBinServerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug SmartTrashBinServerWeb.SoracomAuthPlug
  end

  pipeline :device_request do
    plug :accepts, ["json"]
    # plug :fetch_device
  end

  scope "/", SmartTrashBinServerWeb do
    pipe_through :browser

    live "/chart", ChartLive
    live "/demo", Demo
  end

  # Other scopes may use custom stacks.
  scope "/api", SmartTrashBinServerWeb do
    pipe_through :api
    post "/trash_capacity_histories", TrashCapacityHistoryController, :create
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    scope "/" do
      pipe_through :browser
      live_dashboard "/telemetry_dashboard", metrics: SmartTrashBinServerWeb.Telemetry
    end
  end

  ## Authentication routes
  scope "/", SmartTrashBinServerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  scope "/", SmartTrashBinServerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", SmartTrashBinServerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", DashboardLive, :index
    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    get "/payments/:target_address/confirmation", PaymentsController, :confirmation
    post "/payments", PaymentsController, :create
    resources "/trash_bins", TrashBinsController
  end

  scope "/admin", SmartTrashBinServerWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/users", UserController
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      surface_catalogue("/catalogue")
    end
  end

  # scope "/admin", SmartTrashBinServerWeb.Admin, as: :admin do
  #   pipe_through :browser
  #   # resources "/users", UserController
  # end
end
