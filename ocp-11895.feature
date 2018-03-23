Feature: Evacuate node with dry run option should only list but not actually do the remove
# @author weinliu@redhat.com
# @case_id OCP-11895
@admin
Scenario: Evacuate node with dry run option should only list but not actually do the remove
    Given I have a project
    When I run the :create client command with:
      | f | https://raw.githubusercontent.com/weinliu/myfiles/master/hello-pod |
    Then the step should succeed
    When I run the :create client command with:
      | f | https://raw.githubusercontent.com/weinliu/myfiles/master/hello-pod-team-qe | 
    Then the step should succeed                                                                                            
    Given 1 pods become ready with labels:
      | team=qe | 
   # Then the step should succeed

    Given I register clean-up steps:                                                                                   
    """
    When I run the :label admin command with:
      | resource | node|                                                                                         
      | name     | <%= cb.nodes[1].name %> |
      | key_val| team-|
    """
    #When I run the :oadm_manage_node admin command with:
    # | node_name   | <%= cb.pod_nodes[0].name %> |
    # | schedulable | true               |
    #When I run the :oadm_manage_node admin command with:                                                                    
    #  | node_name   | <%= cb.pod_nodes[1].name %> |
    #  | schedulable | true 
   Given I store the schedulable nodes in the :nodes clipboard                                                             
    When I run the :oadm_drain admin command with:
      | node_name | <%= cb.nodes[0].name %>  |
      | pod_selector | team=qe |
      | dry_run | true |
    Then the output should match 1 times:
      |node.*cordoned.*dry\s+run.*|
      |node.*drained.*dry\s+run.*|

# repeat steps above as per test case
#
    When I run the :label admin command with:
      | resource | node|                                                                                         
      | name     | <%= cb.nodes[1].name %> |
      | key_val| team=dev |
    Then the step should succeed

    When I run the :oadm_drain admin command with:
      | selector | team=dev |
      | dry_run | true |
    Then the output should match:      
      | node.*cordoned.*dry\s+run.* |    
      | node.*drained.*dry\s+run.* |     
 
    When I run the :oadm_manage_node admin command with:                                                                   
      | node_name   | <%= cb.nodes[0].name %> |
      | list_pods || 
    Then the step should succeed

   When I run the :oadm_manage_node admin command with:                                                                   
      | node_name   | <%= cb.nodes[1].name %> |
      | list_pods || 
    Then the step should succeed

   When I run the :get client command with:                                                                   
      | resource | pod |
   Then the output should match 2 times:
      | hello-pod |
 

