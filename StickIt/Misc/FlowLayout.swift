//
//  FlowLayout.swift
//  InStick
//
//  Created by Alexander Rivera on 4/10/25.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 0
    var alignment: FlowAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, spacing: spacing, containerWidth: containerWidth, alignment: alignment).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, spacing: spacing, containerWidth: bounds.width, alignment: alignment).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }
}

enum FlowAlignment {
    case leading, center, trailing
}

func layout(sizes: [CGSize],
            spacing: CGFloat = 0,
            containerWidth: CGFloat,
            alignment: FlowAlignment = .leading) -> (offsets: [CGPoint], size: CGSize) {
    
    var result: [CGPoint] = []
    var currentPosition: CGPoint = .zero
    var lineHeight: CGFloat = 0
    var maxX: CGFloat = 0
    
    var rows: [[CGSize]] = []
    var currentRow: [CGSize] = []
    
    for size in sizes {
        if currentPosition.x + size.width > containerWidth {
            rows.append(currentRow)
            currentRow = []
            currentPosition.x = 0
            currentPosition.y += lineHeight + spacing
            lineHeight = 0
        }
        currentRow.append(size)
        currentPosition.x += size.width + spacing
        lineHeight = max(lineHeight, size.height)
    }
    
    if !currentRow.isEmpty { rows.append(currentRow) }
    
    var yOffset: CGFloat = 0
    for row in rows {
        let rowWidth = row.reduce(0) { $0 + $1.width } + spacing * CGFloat(row.count - 1)
        var xOffset: CGFloat
        switch alignment {
        case .leading:
            xOffset = 0
        case .center:
            xOffset = (containerWidth - rowWidth) / 2
        case .trailing:
            xOffset = containerWidth - rowWidth
        }
        
        for size in row {
            result.append(CGPoint(x: xOffset, y: yOffset))
            xOffset += size.width + spacing
        }
        yOffset += (row.map { $0.height }.max() ?? 0) + spacing
        maxX = max(maxX, rowWidth)
    }
    
    return (result, CGSize(width: maxX, height: yOffset))
}
