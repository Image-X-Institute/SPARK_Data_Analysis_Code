import re
 
def read_file(filepath):
    with open(filepath, 'r', encoding='latin-1') as f:
        return f.read()
 
# Load both files
before = read_file(r"C:\Users\ayan7521\OneDrive - The University of Sydney (Staff)\Desktop\zzzBeamModelReview2023_10FFF_10FFF_20250522075008.bin")
after  = read_file(r"C:\Users\ayan7521\OneDrive - The University of Sydney (Staff)\Desktop\4451684219141943744293_10FFF_10FFF_20250522075008.bin")  # update this path
 
# Check specific fields
fields = ['Patient ID', 'Plan Name', 'Plan UID', 'BeamName']
 
print("── FIELD COMPARISON ──\n")
for field in fields:
    # Extract value using regex
    before_match = re.search(rf'{field}:[ \t]*([^\s\x00]+)', before)
    after_match  = re.search(rf'{field}:[ \t]*([^\s\x00]+)', after)
 
    before_val = before_match.group(1) if before_match else 'NOT FOUND'
    after_val  = after_match.group(1)  if after_match  else 'NOT FOUND'
 
    status = "✓ CHANGED" if before_val != after_val else "✗ UNCHANGED"
    print(f"{field}:")
    print(f"  Before: {before_val}")
    print(f"  After:  {after_val}")
    print(f"  Status: {status}\n")