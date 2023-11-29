// ----------------------------------------------------------------------------------------------------
// This is a starter that creates a simple dashboard -- it needs more work!
// ----------------------------------------------------------------------------------------------------
// See: 
//   https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-monitoring
//   https://learn.microsoft.com/en-us/azure/azure-portal/quick-create-bicep?tabs=CLI
//   https://github.com/azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.portal/azure-portal-dashboard
// ----------------------------------------------------------------------------------------------------
param dashboardName string = ''
param dashboardDisplayName string = ''

param clusterResourceGroup string = ''
param clusterName string = ''

param location string = resourceGroup().location
param commonTags object = {}

// --------------------------------------------------------------------------------
var templateTag = { TemplateFile: '~loganalytics.bicep' }
var titleTag = { 'hidden-title': dashboardDisplayName }
var tags = union(commonTags, templateTag, titleTag)

// --------------------------------------------------------------------------------
resource dashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = {
  name: dashboardName
  location: location
  tags: tags
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '## Azure AKS Monitor\r\nThis dashboard will contain metrics for our AKS Clusters.'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 3
              y: 0
              rowSpan: 4
              colSpan: 6
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: 'This is the team dashboard for  AKS monitoring for our team. Here are some useful links:\r\n\r\n1. [Analyze metrics with Azure Monitor ](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/analyze-metrics#pin-charts-to-dashboards)\r\n1. [Overview of Log Analytics in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)\r\n1. [Azure Monitor documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/)'
                    title: 'AKS Monitoring Dashboard'
                    subtitle: 'Site Reliability Team'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 9
              y: 0
              rowSpan: 4
              colSpan: 6
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/VideoPart'
              settings: {
                content: {
                  settings: {
                    src: 'https://www.youtube.com/watch?v=GetnBRKNXco'
                    autoplay: false
                  }
                }
              }
            }
          }
            {
            position: {
              x: 0
              y: 4
              rowSpan: 3
              colSpan: 11
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: resourceId(clusterResourceGroup, 'microsoft.containerservice/managedclusters', clusterName)
                          }
                          name: 'kube_pod_status_ready'
                          aggregationType: 4
                          namespace: 'microsoft.containerservice/managedclusters'
                          metricVisualization: {
                            displayName: 'Number of pods in Ready state'
                            resourceDisplayName: clusterName
                          }
                        }
                      ]
                      title: 'Avg Number of pods in Ready state for ${clusterName}'
                      titleKind: 1
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      timespan: {
                        relative: {
                          duration: 86400000
                        }
                        showUTCTime: true
                        grain: 1
                      }
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                          id: resourceId(clusterResourceGroup, 'microsoft.containerservice/managedclusters', clusterName)
                          }
                          name: 'kube_pod_status_ready'
                          aggregationType: 4
                          namespace: 'microsoft.containerservice/managedclusters'
                          metricVisualization: {
                            displayName: 'Number of pods in Ready state'
                            resourceDisplayName: clusterName
                          }
                        }
                      ]
                      title: 'Avg Number of pods in Ready state for ${clusterName}'
                      titleKind: 1
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
          // {
          //   position: {
          //     x: 0
          //     y: 4
          //     rowSpan: 3
          //     colSpan: 11
          //   }
          //   metadata: {
          //     inputs: [
          //       {
          //         name: 'queryInputs'
          //         value: {
          //           timespan: {
          //             duration: 'PT1H'
          //           }
          //           id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //           chartType: 0
          //           metrics: [
          //             {
          //               name: 'Percentage CPU'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //           ]
          //         }
          //       }
          //     ]
          //     type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
          //   }
          // }
          // {
          //   position: {
          //     x: 0
          //     y: 7
          //     rowSpan: 2
          //     colSpan: 3
          //   }
          //   metadata: {
          //     inputs: [
          //       {
          //         name: 'queryInputs'
          //         value: {
          //           timespan: {
          //             duration: 'PT1H'
          //           }
          //           id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //           chartType: 0
          //           metrics: [
          //             {
          //               name: 'Disk Read Operations/Sec'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //             {
          //               name: 'Disk Write Operations/Sec'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //           ]
          //         }
          //       }
          //     ]
          //     type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
          //   }
          // }
          // {
          //   position: {
          //     x: 3
          //     y: 7
          //     rowSpan: 2
          //     colSpan: 3
          //   }
          //   metadata: {
          //     inputs: [
          //       {
          //         name: 'queryInputs'
          //         value: {
          //           timespan: {
          //             duration: 'PT1H'
          //           }
          //           id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //           chartType: 0
          //           metrics: [
          //             {
          //               name: 'Disk Read Bytes'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //             {
          //               name: 'Disk Write Bytes'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //           ]
          //         }
          //       }
          //     ]
          //     type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
          //   }
          // }
          // {
          //   position: {
          //     x: 6
          //     y: 7
          //     rowSpan: 2
          //     colSpan: 3
          //   }
          //   metadata: {
          //     inputs: [
          //       {
          //         name: 'queryInputs'
          //         value: {
          //           timespan: {
          //             duration: 'PT1H'
          //           }
          //           id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //           chartType: 0
          //           metrics: [
          //             {
          //               name: 'Network In Total'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //             {
          //               name: 'Network Out Total'
          //               resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //             }
          //           ]
          //         }
          //       }
          //     ]
          //     type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
          //   }
          // }
          // {
          //   position: {
          //     x: 9
          //     y: 7
          //     rowSpan: 2
          //     colSpan: 2
          //   }
          //   metadata: {
          //     inputs: [
          //       {
          //         name: 'id'
          //         value: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
          //       }
          //     ]
          //     type: 'Extension/Microsoft_Azure_Compute/PartType/VirtualMachinePart'
          //     asset: {
          //       idInputName: 'id'
          //       type: 'VirtualMachine'
          //     }
          //   }
          // }
        ]
      }
    ]
  }
}
