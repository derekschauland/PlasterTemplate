Function Get-DSCallingFunction
{
    
    $callStack = Get-PSCallStack
    If ($callStack.Count -gt 1)
    {
        '{0}' -f $callStack[1].FunctionName
    }
}