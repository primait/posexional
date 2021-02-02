# ExCheck.start
Application.ensure_all_started(:timex)
ExUnit.start(exclude: [:experiments])
