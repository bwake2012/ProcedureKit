//
//  ContactsCondition.swift
//  Operations
//
//  Created by Daniel Thorpe on 24/09/2015.
//  Copyright © 2015 Dan Thorpe. All rights reserved.
//

import Contacts

@available(iOS 9.0, OSX 10.11, *)
public struct _ContactsCondition<Store: ContactsPermissionRegistrar>: OperationCondition {

    public let name = "Contacts"
    public let isMutuallyExclusive = false

    let entityType: CNEntityType
    let registrar: Store

    public init(entityType: CNEntityType = .Contacts) {
        self.entityType = entityType
        registrar = Store()
    }

    init(entityType: CNEntityType = .Contacts, registrar: Store) {
        self.entityType = entityType
        self.registrar = registrar
    }

    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        switch registrar.opr_authorizationStatusForEntityType(entityType) {
        case .NotDetermined:
            return _ContactsAccess(entityType: entityType, contactStore: registrar)
        default:
            return .None
        }
    }

    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        switch registrar.opr_authorizationStatusForEntityType(entityType) {
        case .Authorized:
            completion(.Satisfied)
        case .Denied:
            completion(.Failed(ContactsPermissionError.AuthorizationDenied))
        case .Restricted:
            completion(.Failed(ContactsPermissionError.AuthorizationRestricted))
        case .NotDetermined:
            completion(.Failed(ContactsPermissionError.AuthorizationNotDetermined))
        }
    }
}

@available(iOS 9.0, OSX 10.11, *)
public typealias ContactsCondition = _ContactsCondition<CNContactStore>
