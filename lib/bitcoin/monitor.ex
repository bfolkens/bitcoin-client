defmodule Bitcoin.Monitor do
  defmacro __using__(streams: streams) do
    quote do
      use GenServer

      def start_link(opts) when is_list(opts) do
        GenServer.start_link(__MODULE__, opts)
      end

      def init(_opts) do
        {:ok, socket} = connect(unquote(streams))

        {:ok, socket, {:continue, unquote(streams)}}
      end

      defp connect(streams) do
        {:ok, socket} = Bitcoin.ZMQ.connect(streams)

        parent_pid = self()

        spawn_link(fn ->
          socket
          |> Bitcoin.ZMQ.stream()
          |> Stream.each(&send(parent_pid, &1))
          |> Stream.run()
        end)

        {:ok, socket}
      end
    end
  end
end
