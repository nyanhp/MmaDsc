[DscResource()]
class WorkspaceConfiguration
{
    [DscProperty(Key)]
    [string]
    $WorkspaceId

    [DscProperty(Mandatory)]
    [pscredential]
    $WorkspaceKey

    [DscProperty()]
    [string]
    $ProxyUri

    [DscProperty()]
    [pscredential]
    $ProxyCredential

    [DscProperty()]
    [ensure]
    $Ensure

    [DscProperty(NotConfigurable)]
    [int32]
    $ConnectionStatus

    [DscProperty(NotConfigurable)]
    [string]
    $ConnectionStatusText
    
    # Gets the resource's current state.
    [WorkspaceConfiguration] Get()
    {        
        $agentCfg = New-Object -ComObject AgentConfigManager.MgmtSvcCfg
        $workspace = $agentCfg.GetCloudWorkspace($this.WorkspaceId)
        $this.WorkspaceId = $workspace.WorkspaceId
        $this.ProxyUri = $agentCfg.ProxyUrl
        $this.ConnectionStatus = if ($null -eq $workspace) { -1 } else { $workspace.ConnectionStatus }
        $this.ConnectionStatusText = $workspace.ConnectionStatusText
        return $this
    }
    
    # Sets the desired state of the resource.
    [void] Set()
    {
        $agentCfg = New-Object -ComObject AgentConfigManager.MgmtSvcCfg

        if ($this.Ensure -eq 'Absent')
        {
            $agentCfg.RemoveCloudWorkspace($this.WorkspaceId)
            $agentCfg.ReloadConfigurations()
            return
        }
    
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

        $agentCfg.AddCloudWorkspace($this.WorkspaceId, $this.WorkspaceKey.GetNetworkCredential().Password)

        $agentCfg.ReloadConfigurations()
    }
    
    # Tests if the resource is in the desired state.
    [bool] Test()
    {
        $status = $this.Get()

        if ($this.Ensure -eq 'Absent' -and $null -ne $status.WorkspaceId)
        {
            return $false
        }

        if ($this.Ensure -eq 'Present' -and $null -eq $status.WorkspaceId)
        {
            return $false
        }
    
        if ($this.Ensure -eq 'Present' -and $status.ConnectionStatus -ne 0)
        {
            return $false
        }

        if ($this.Ensure -eq 'Present' -and $null -ne $this.ProxyUri -and $this.ProxyUri -ne $status.ProxyUri)
        {
            return $false
        }

        return $true
    }
}
