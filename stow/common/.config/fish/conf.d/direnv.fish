# direnv integration
# Target: common
# Version: 1.0

if type -q direnv
    direnv hook fish | source
end
