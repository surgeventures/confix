defmodule Confix.PatchTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Mix.Config

  describe "init/1" do
    test "patch whole app" do
      System.put_env("SOME_VAR", "some var")
      System.put_env("OTHER_VAR", "other var")

      Config.persist(confix: [patch: [
        sample_external_app: []]])

      Config.persist(sample_external_app: [
        some_key: {:system, "SOME_VAR"},
        other_key: [
          deep_key: {:system, "OTHER_VAR"}
        ]])

      capture_log(fn ->
        Confix.Application.init(nil)
      end)

      assert Application.get_all_env(:sample_external_app) == [
        other_key: [deep_key: "other var"],
        some_key: "some var"
      ]
    end

    test "patch single key" do
      System.put_env("SOME_VAR", "some var")
      System.put_env("OTHER_VAR", "other var")

      Config.persist(confix: [patch: [
        sample_external_app: :some_key]])

      Config.persist(sample_external_app: [
        some_key: {:system, "SOME_VAR"},
        other_key: [
          deep_key: {:system, "OTHER_VAR"}
        ]])

      capture_log(fn ->
        Confix.Application.init(nil)
      end)

      assert Application.get_all_env(:sample_external_app) == [
        other_key: [deep_key: {:system, "OTHER_VAR"}],
        some_key: "some var"
      ]
    end

    test "patch single nested key" do
      System.put_env("SOME_VAR", "some var")
      System.put_env("OTHER_VAR", "other var")

      Config.persist(confix: [patch: [
        sample_external_app: [:other_key, :deep_key]]])

      Config.persist(sample_external_app: [
        some_key: {:system, "SOME_VAR"},
        other_key: [
          deep_key: {:system, "OTHER_VAR"},
          deep_key_2: {:system, "OTHER_VAR"}
        ]])

      capture_log(fn ->
        Confix.Application.init(nil)
      end)

      assert Application.get_all_env(:sample_external_app) == [
        other_key: [deep_key: "other var", deep_key_2: {:system, "OTHER_VAR"}],
        some_key: {:system, "SOME_VAR"}
      ]
    end
  end
end
