// ... imports ...
// inside _HistoryScreenState build method:

// ...
                      // Date Range Filter Pill
                      InkWell(
                        onTap: () => _pickDateRange(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 12, 
                            right: _selectedDateRange != null ? 8 : 12, 
                            top: 8, 
                            bottom: 8
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: kUnpaidContainerColor),
                            borderRadius: BorderRadius.circular(20),
                            // REVERTED: withValues -> withOpacity
                            color: _selectedDateRange != null ? kUnpaidContainerColor.withOpacity(0.2) : Colors.transparent,
                          ),
// ... rest of file