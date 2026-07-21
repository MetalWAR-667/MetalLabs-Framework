import sys
import os

# Ensure the parent directory is in the path to allow imports from app
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.ui import Application

def main():
    app = Application()
    app.mainloop()

if __name__ == "__main__":
    main()
