//
//  CellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public protocol CellPresenter {
    var reuseIdentifier: String { get }
    func configureCell(cell: UICollectionViewCell)
}
