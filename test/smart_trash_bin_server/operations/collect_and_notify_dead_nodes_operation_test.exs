defmodule SmartTrashBinServer.CollectAndNotifyDeadNodesOperationTest do
  use SmartTrashBinServer.DataCase

  alias SmartTrashBinServer.CollectAndNotifyDeadNodesOperation

  describe "send_email" do
    test "empty dead_nodes" do
      dead_nodes = []
      assert dead_nodes = CollectAndNotifyDeadNodesOperation.send_email(dead_nodes)
    end
  end
end
