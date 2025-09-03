public class philboTest {

	private Set<Id> getRoleTree ( Map<Id , List<UserRole>> roleChildrenById , Id rid ) {
		Set<Id> roleTreeSet = new Set<Id> { rid };
		Set<Id> childRoleSet = new Set<Id> {};
		if ( !roleChildrenById.containsKey ( rid ) ) {
			return roleTreeSet;
		}
		for ( UserRole ur : roleChildrenById.get ( rid ) ) {
			childRoleSet.add ( ur.Id );
		}
		if ( !childRoleSet.isEmpty () ) {
			roleTreeSet.addAll ( childRoleSet );
			for ( Id crid : childRoleSet ) {
				roleTreeSet.addAll ( getRoleTree ( roleChildrenById , crid ) );
			}
		}
		return roleTreeSet;
	}

	public Set<Id> getUserGroups ( Id userId , Id roleId ) {
		
		Set<Id> userGrpIdSet = new Set<Id> {};

//		Grab the Groups we're interested in:
//		* The specified Role's pseudo-Group.
//		* All "Regular" Groups.
//		------------------------------------
		Map<Id , Group> allGrpById = new Map<Id , Group> {};
		Id roleGrpId;
		for ( Group grp : [select Id , RelatedId , Type , Name from Group
							where Type = 'Regular'
							or ( Type = 'Role' and RelatedId = :roleId )] 
					) {
			if ( grp.Type == 'Role' ) {
				roleGrpId = grp.Id;
			}
			allGrpById.put ( grp.Id , grp );
//			System.debug ( 'GRP : [' + grp + ']' );
		}
	
//		Grab the GroupMembers we're interested in:
//		* GroupMembers which are the specified userId.
//		* GroupMembers which are Groups themselves.
//		----------------------------------------------
		Map<Id , GroupMember> parentGMByGId = new Map<Id , GroupMember> {};
		for ( GroupMember gm : [select Id , GroupId , UserOrGroupId from GroupMember
								where UserOrGroupId = :userId
								or UserOrGroupId in :allGrpById.keySet ()]
						) {
			if ( gm.UserOrGroupId != userId ) {
				parentGMByGId.put ( gm.UserOrGroupId , gm );
			}
			else if ( allGrpById.containsKey ( gm.GroupId ) ) {
				userGrpIdSet.add ( gm.GroupId );
			}
		}

//		Now go thru and grab the groups we're interested in.
//		----------------------------------------------------
		Set<Id> startingGrpSet = new Set<Id> ( userGrpIdSet );
		startingGrpSet.add ( roleGrpId );
		for ( Id gid : startingGrpSet ) {
			while ( parentGMByGId.containsKey ( gid ) ) {
				Id parentGId = parentGMByGId.get ( gid ).GroupId;
				if ( allGrpById.containsKey ( parentGId ) ) {
					userGrpIdSet.add ( parentGId );
				}
				gid = parentGId;
			}
		}

		return userGrpIdSet;
	}
			
	public void xxx () {
		Map<Id , UserRole> roleById = new Map<Id , UserRole> {};
		Map<Id , List<UserRole>> roleChildrenById = new Map<Id , List<UserRole>> {};
		Set<Id> rootRoleSet = new Set<Id> {};
		
		for ( UserRole ur : [select Id , Name , ParentRoleId from UserRole] ) {
			roleById.put ( ur.Id , ur );
			if ( ur.ParentRoleId != Null ) {
				if ( !roleChildrenById.containsKey ( ur.ParentRoleId ) ) {
					roleChildrenById.put ( ur.ParentRoleId , new List<UserRole> {} );
				}
				roleChildrenById.get ( ur.ParentRoleId ).add ( ur );
			}
			else {
				rootRoleSet.add ( ur.Id );
			}
		}
		
		for ( Id rid : rootRoleSet ) {
			System.debug ( 'ID : [' + rid + '] [' + getRoleTree ( roleChildrenById , rid ) + ']' );
		}
			
		Map<Id , Group> roleGrpById = new Map<Id , Group> {};
		Map<Id , Group> allGrpById = new Map<Id , Group> {};
		
		for ( Group g : [select Name , RelatedId , Type from Group] ) {
			if ( roleById.containsKey ( g.RelatedId ) && g.Type == 'Role' ) {
				roleGrpById.put ( g.RelatedId , g );
			}
			allGrpById.put ( g.Id , g );
		}
		
		System.debug ( 'ROLE GROUPS:' );
		for ( Id rid : roleGrpById.keySet () ) {
			System.debug ( rid + ' (' + roleById.get ( rid ).Name + ') : [' + roleGrpById.get ( rid ).Id + ']' );
		}
		System.debug ( 'REGULAR GROUPS:' );
		for ( Id gid : allGrpById.keySet () ) {
			System.debug ( gid + ' : ' + allGrpById.get ( gid ).Name );
		}
		
		Map<Id , GroupMember> parentGMByGId = new Map<Id , GroupMember> {};
		Set<Id> parentGIdSet = new Set<Id> {};
		for ( GroupMember gm : [select Group.Id , Group.Name , UserOrGroupId from GroupMember
								where UserOrGroupId in :allGrpById.keySet ()]
							) {
			System.debug ( 'GRP [' + gm.Group.Id + '] IS A PARENT OF [' + gm.UserOrGroupId + ']' ); 
			parentGMByGId.put ( gm.UserOrGroupId , gm );
			parentGIdSet.add ( gm.Group.Id );
		}

		System.debug ( 'ROLE PARENTING:' );
		for ( Id rid : roleById.keySet () ) {
			String s = '\nROLE ' + roleById.get ( rid ).Name + '\n';
			for ( ID crid : getRoleTree ( roleChildrenById , rid ) ) {
				s += '...' + roleById.get ( crid ).Name + '\n';
			}
			System.debug ( s );
		}	
		System.debug ( 'ROLE GROUP PARENTING:' );
		for ( Id gid : parentGMByGId.keySet () ) {
			System.debug ( gid + ' [' + allGrpbyId.get ( gid ).Name + '] : ' + parentGMByGId.get ( gid ).Group.Name );
		}
		
		for ( Id rid : roleGrpById.keySet () ) {
			String s = '\nROLE ' + roleById.get ( rid ).Name + '\n';
			Id gid = roleGrpById.get ( rid ).Id;
			s += '(gid ' + gid + ')\n'; 
			while ( gid != Null ) {
				GroupMember gm = parentGMByGId.get ( gid );
				if ( gm != Null ) {
					s += '...' + gm.Group.Name + '\n';
					gid = gm.Group.Id;
				}
				else {
					gid = Null;
				}
			}
			System.debug ( s );
		}
		
		for ( Id gid : parentGMByGId.keySet () ) {
			if ( parentGIdSet.contains ( gid ) ) {
				continue;
			}
			String s = '\nGROUP ' + allGrpById.get ( gid ).Name + '\n';
			while ( gid != Null ) {
				GroupMember gm = parentGMByGId.get ( gid );
				if ( gm != Null ) {
					s += '...' + gm.Group.Name + '\n';
					gid = gm.Group.Id;
				}
				else {
					gid = Null;
				}
			}
			System.debug ( s );
		}	
	}
}