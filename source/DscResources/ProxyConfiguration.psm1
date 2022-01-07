[DscResource()]
class ProxyConfiguration
{
    [DscProperty(Key)]
    [string]
    $ProxyUri

    [DscProperty()]
    [pscredential]
    $ProxyCredential

    [DscProperty()]
    [ensure]
    $Ensure
    
    # Gets the resource's current state.
    [ProxyConfiguration] Get()
    {
        $agentCfg = New-Object -ComObject AgentConfigManager.MgmtSvcCfg
        $this.ProxyUri = $agentCfg.ProxyUrl
        return $this
    }
    
    # Sets the desired state of the resource.
    [void] Set()
    {
        $agentCfg = New-Object -ComObject AgentConfigManager.MgmtSvcCfg
    
        if ($this.ProxyUri)
        {
            $agentCfg.SetProxyUrl($this.ProxyUri)
        }
        else
        {
            $agentCfg.SetProxyUrl('')
        }

        if ($this.ProxyCredential)
        {
            $agentCfg.SetProxyCredential($this.ProxyCredential.UserName, $this.ProxyCredential.GetNetworkCredential().Password)
        }
    }
    
    # Tests if the resource is in the desired state.
    [bool] Test()
    {
        $status = $this.Get()

        if ($this.Ensure -eq 'Absent' -and $status.ProxyUri)
        {
            return $false
        }

        if ($this.Ensure -eq 'Absent' -and $null -eq $status.ProxyUri)
        {
            return $false
        }

        return $false
    }
}
