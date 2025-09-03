/*
 * Name:        grpRoleProfileUtil.cls
 *
 * Description: Functions to determine Group, Role and Profile membership.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from STC StraightThrough.
 */
 
public class grpRoleProfileUtil {

//	============================================================================
//	Method:	getUserGrpsAndRoles
//
//	Desc:	Utility to determine the specified UserId's Public Groups, plus 
//			their Parent Groups, all the way to the top of the Group hierarchy.
//			Optionally, also retrieve the subordinate Roles to the specified
//			Role.
//
//	Args:	userId - Id of the User whose Groups we're interested in
//			coreRoleId - Id of the Role whose subordinates we're interested in.
//			             Set this to Null to suppress Role tree traversal.
//
//	Return:	A keyString -> Set<Id> map, where keyString is either 
//			'ROLE' or 'GROUP' and the corresponding Set<Id> is a set of
//			Role or Group Ids.
//	============================================================================	
	public static Map<String , Set<Id>> getUserGrpsAndRoles ( Id userId , Id coreRoleId ) {
		
//		Initialize the return data structure.
//		-------------------------------------
		Map<String , Set<Id>> grpRoleMap = new map<String , Set<Id>> {
											featureCacheUtil.ROLE_STRING => new Set<Id> {} ,
											featureCacheUtil.GROUP_STRING => new Set<Id> {}
										};

//		Grab all groups from the system.
//		--------------------------------
		Id[] allGrpIds = new Id[] {};
		Id[] coreGrpIds = new Id[] {};

		for ( Group g : [ select
							Id , Type , RelatedId
						from
							Group
						where 
							Type in ( :featureCacheUtil.REGULAR_GROUP_TYPE , 
										:featureCacheUtil.ROLE_GROUP_TYPE )
						]
		) {
			if ( coreRoleId != Null && g.Type == featureCacheUtil.ROLE_GROUP_TYPE 
					&& g.RelatedId == coreRoleId ) {
				coreGrpIds.add ( g.Id );
				allGrpIds.add ( g.Id );
			}
			else if ( g.Type == featureCacheUtil.REGULAR_GROUP_TYPE ) {
				allGrpIds.add ( g.Id );
			}
		}
														
//		Grab the User's core groups from the system, and also create a Grp -> ParentGrp map.
//		------------------------------------------------------------------------------------
		Map<Id , Id> parentGrpIdByGrp = new Map<Id , Id> {};
		for ( GroupMember gm : [ select
									GroupId , 
									UserOrGroupId
								from
									GroupMember
								where
									UserOrGroupId = :userId or
									UserOrGroupId in :allGrpIds
								]
		) {
			if ( gm.UserOrGroupId == userId ) {
				coreGrpIds.add ( gm.GroupId );
			}
			else {
				parentGrpIdByGrp.put ( gm.UserOrGroupId , gm.GroupId );
			}
		}
		
		if ( coreGrpIds.isEmpty() ) {
			return grpRoleMap;
		}
		
//		Grab the User's Role group, and all child Roles, from the system.
//		-----------------------------------------------------------------
		if ( coreRoleId != Null ) {		
			grpRoleMap.get ( featureCacheUtil.ROLE_STRING ).addAll ( getRoleFamily ( coreRoleId , Null ) );
		}
		
//		Grab all our groups' Parent groups from the system.
//		---------------------------------------------------
		Set<Id> parentGrpIds = new Set<Id> {};		
		for ( Id grpId : coreGrpIds ) {
			Id parentGrpId = parentGrpIdByGrp.get ( grpId );
			while ( parentGrpId != Null ) {
				if ( !parentGrpIds.add ( parentGrpId ) ) {
					break;
				}
				parentGrpId = parentGrpIdByGrp.get ( parentGrpId );
			}
		}
		
		for ( Id parentGrpId : parentGrpIds ) {
			coreGrpIds.add ( parentGrpId );
		}

		grpRoleMap.get ( featureCacheUtil.GROUP_STRING ).addAll ( coreGrpIds );
		
		return grpRoleMap;
	}		

//	============================================================================
//	Method:	getRoleFamily
//
//	Desc:	Utility to roll down the Role hierarchy , starting at the specified
//			Role Id, and get a list consisting of the specified Role and all its
//			subordinate Roles, recursively down to the bottom of the hierarchy.
//	
//	Args:	roleId - The Role we're interested in
//			roleIdsByParentRole - Map of <ParentRoleId , List<ChildRoleId>>
//
//	Return:	A set containing the Role Id and all its subordinate Role Ids.
//	============================================================================	
	public static Set<Id> getRoleFamily ( Id startRoleId , Map<Id , Id[]> roleIdsByParentRole ) {
		
//		Seed ourselves with all Roles, if we haven't done so already.
//		-------------------------------------------------------------
		if ( roleIdsByParentRole == Null ) {
			roleIdsByParentRole = new Map<Id , Id[]> {};
			
			for ( UserRole role : [ select Id , Name , ParentRoleId 
										from UserRole
									]
			) {
				if ( !roleIdsByParentRole.containsKey ( role.ParentRoleId ) ) {
					roleIdsByParentRole.put ( role.ParentRoleId , new Id[] {} );
				}
				roleIdsByParentRole.get ( role.ParentRoleId ).add ( role.Id );
			}
		}
		
		Set<Id> roleFamilyIdSet = new Set<Id> {};
		roleFamilyIdSet.add ( startRoleId );
		
		Id[] childRoleIds = roleIdsByParentRole.get ( startRoleId );
		if ( childRoleIds != Null ) {
			for ( Id childRoleId : childRoleIds ) {
				
//				Recurse down each child Role, to find ITS own descendants.
//				----------------------------------------------------------				
				roleFamilyIdSet.addAll ( getRoleFamily ( childRoleId , roleIdsByParentRole ) );
			}
		} 
		
		return roleFamilyIdSet;
	}	
}