library(yaml)

print("Test yaml...");

# test basic yaml
expect_equal(as.yaml(1:10),"- 1\n- 2\n- 3\n- 4\n- 5\n- 6\n- 7\n- 8\n- 9\n- 10\n")

print("Success!");
