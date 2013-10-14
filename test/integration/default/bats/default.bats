# vim: ft=sh:
# only run on rhel
@test "should have gdash running" {
  [ "$(ps aux | grep gdash | grep -v grep)" ]
}
