# [ .nodes[( .nodes[.root].inputs[] )].locked
#   | { (.owner + "/" + .repo) : .rev }] 
# | reduce .[] as $i ( {};
#   . + $i)
#
# (with jq -r)
.nodes | .[.root.inputs[]] | .locked | "\(.owner)/\(.repo): \(.rev[0:6])"
#

# [.nodes
#   | .[.root.inputs[]]
#   | .locked
#   | { key: "\(.owner)/\(.repo)",
#       value: .rev[0:8] }]
# | from_entries
